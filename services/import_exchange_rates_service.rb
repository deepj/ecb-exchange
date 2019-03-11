# frozen_string_literal: true

require 'securerandom'

require 'lib/ecb_exchange_rates/fetcher'
require 'lib/ecb_exchange_rates/processor'

class ImportExchangeRatesService
  include Dry::Transaction

  step :fetch
  step :process
  step :persist

  def fetch(_input)
    ECBExchangeRates::Fetcher.new.()
  end

  def process(input)
    ECBExchangeRates::Processor.new.(input)
  end

  def persist(input)
    temporary_table = :"exchange_rates_import_#{SecureRandom.hex(5)}"

    DB.transaction(rollback: :reraise) do
      DB.run %(CREATE TEMPORARY TABLE "#{temporary_table}" (LIKE "exchange_rates") ON COMMIT DROP)
      DB.copy_into(temporary_table, data: input, format: :csv)
      DB[:exchange_rates].insert_conflict.insert(DB[temporary_table])
    end

    Success(true)
  rescue Sequel::Error
    Failure(:persistence_failed)
  end
end
