# frozen_string_literal: true

require 'bundler'
require 'irb'
require 'csv'
require 'logger'
require 'securerandom'
require 'dry/validation'

Bundler.require(:default, ENV.fetch('RACK_ENV', 'development'))
require 'down'

exchange_rates_stream = Down.open('http://sdw.ecb.europa.eu/quickviewexport.do?SERIES_KEY=120.EXR.D.USD.EUR.SP00.A&type=csv')
exchange_rates_stream2 = Down.open('http://sdw.ecb.europa.eu/quickviewexport.do?SERIES_KEY=120.EXR.D.USD.EUR.SP00.A&type=csv')
binding.irb
# Taken from https://stackoverflow.com/a/22061799/8538244 and slightly modified
valid_date = /\A(2\d{3})-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])/

# while line = exchange_rates_stream.gets
#   break if line.match?(valid_date)
# end

# Rewind the cursor to the beginning of the line
# exchange_rates_stream.seek(-line.size, IO::SEEK_CUR)

prod = Enumerator.new do |yielder|
  while line = exchange_rates_stream.gets
    yielder << line
  end
end.lazy

#
# reader, writer = IO.pipe
# headers = true
# producer = Thread.new(exchange_rates_stream, writer, headers) do |stream, mod, skip_headers|
#   line = stream.gets
#   next if skip_headers || !line.match?(valid_date)
#   skip_headers = false if skip_headers
#   puts line.class
# end

# exchange_rates_stream1 = exchange_rates_stream.each_chunk.lazy

# NOTE: There are several approaches how to handle this
modi = prod
         .drop_while { |line| !line.match?(valid_date) }               # Remove headers until finding the first correct data
         .select { |line| !line.match?(/\A(1\d{3})|(-[\r\n]{,2})\z/) } # Select all rows if a row doesn't start by 19 or rate is -
DATABASE_URL = 'postgres://postgres@localhost'

DB = Sequel.connect(DATABASE_URL)
DB.loggers << Logger.new(STDOUT)
# DB.copy_into(:exchange_rates, data: modi, format: :csv, options: %(NULL '-'))

# DB.create_table(:exchange_rates) do
#   primary_key :date, type: :Date
#   BigDecimal :rate, size: [8, 4]
# end
DB[:exchange_rates].delete

temporary_table = "exchange_rates_imports_#{SecureRandom.hex(4)}".to_sym
DB.create_table temporary_table, temp: true do
  primary_key :date, type: :Date
  BigDecimal :rate, size: [8, 4]
end

DB.copy_into(temporary_table, data: modi, format: :csv, options: %(NULL '-'))
DB[:exchange_rates].insert_conflict.insert(DB[temporary_table])


value = DB[:exchange_rates].where { date <= '2011-03-05' }
                           .order(:date.desc)
                           .get { (rate * 120).as(:converted_currency) }

binding.irb
