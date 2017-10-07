# frozen_string_literal: true

require 'bundler/inline'

# Setup a database for this prototype using this commands (tested on Mac with installed PostgreSQL 9.6.5 using Homebrew)
#
# createuser -U postgres mh-assignment
# createdb -U postgres -O mh-assignment leadfeeder-martin-assignment

gemfile do
  source 'https://rubygems.org'

  gem 'down',           '4.1.0'
  gem 'dry-validation', '0.11.1'
  gem 'pg',             '0.21.0'
  gem 'sequel',         '5.1.0'
  gem 'sequel_pg',      '1.7.1', require: 'sequel'
end

require 'irb'
require 'securerandom'
require 'logger'
require 'dry/validation'

ExchangeValidator = Dry::Validation.Form do
  configure do
    option :date_since, 2000

    def self.messages
      super.merge(
        en: {
          errors: {
            date_since?: 'must be greater',
            date_in_future?: 'cannot be in the future'
          }
        }
      )
    end
  end

  required(:date).filled(:date?)
  required(:amount).filled(:decimal?)

  validate(date_since?: :date) do |date|
    date.year >= date_since
  end

  validate(date_in_future?: :date) do |date|
    date <= Date.today
  end
end

DATABASE_URL = 'postgres:///leadfeeder-martin-assignment?user=mh-assignment'

DB = Sequel.connect(DATABASE_URL)
DB.loggers << Logger.new($stdout)

DB.create_table?(:exchange_rates) do
  primary_key :date, type: :Date
  BigDecimal :rate, size: [8, 4]
end

ecb_exchange_csv = Down.open('https://sdw.ecb.europa.eu/quickviewexport.do?SERIES_KEY=120.EXR.D.USD.EUR.SP00.A&type=csv')

# We want to stream csv data while importing them into the database
ecb_exchange_stream = Enumerator.new do |yielder|
  loop do
    yielder << ecb_exchange_csv.gets
    break if ecb_exchange_csv.eof?
  end
end.lazy

row_match   = /\A(2\d{3})-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])/
invalid_row = /\A(1\d{3})|(-[\r\n]{,2})\z/

# Steps:
# - remove headers until finding the first row with data
# - reject all invalid rows if a row starts by 1 or an exchange rate is missing (-)
processed_data = ecb_exchange_stream
                 .drop_while { |line| !line.match?(row_match) }
                 .reject     { |line| line.match?(invalid_row) }

temporary_table = :exchange_rates_import

DB.transaction do
  # Each import is made into a own temporary table
  DB.run %(CREATE TEMPORARY TABLE "#{temporary_table}" (LIKE "exchange_rates") ON COMMIT DROP)
  # DB.create_table temporary_table, temp: true, on_commit: :drop do
  #   primary_key :date, type: :Date
  #   BigDecimal :rate, size: [8, 4]
  # end

  # NOTE: if processed_data are imported (streamed), use ecb_exchange_stream.rewind if you want to work with them again
  DB.copy_into(temporary_table, data: processed_data, format: :csv)
  # Import data from the temporary table
  DB[:exchange_rates].insert_conflict.insert(DB[temporary_table])
end

convert_exchange = lambda do |amount, date|
  validator = ExchangeValidator.(amount: amount, date: date)
  return validator.messages(full: true) if validator.failure?
  converted_amount = DB[:exchange_rates].where { date <= validator.output[:date].to_s }
                                        .reverse_order(:date)
                                        .get { round(validator.output[:amount] / rate, 4) }
  converted_amount ? converted_amount.to_s('F') : 'Unexpected state :('
end

puts convert_exchange[120, '2011-03-05']

# Command tips
# DB[:exchange_rates].count  => count all imported exchange rates
# DB[:exchange_rates].delete => delete all imported exchange rates
# DB[:exchange_rates].where { date <= '2011-03-05' }.reverse_order(:date).get(:rate).to_s('F') => get the exchange rate for the given date
# convert_exchange[120, '2011-03-05'] => convert exchange
# DB[:exchange_rates].where { date <= '2011-03-01' } => remove all dates less than or equal to 2011-03-05

binding.irb
