# frozen_string_literal: true

require 'securerandom'

require 'lib/ecb_exchange_rates/fetcher'
require 'lib/ecb_exchange_rates/processor'

class ImportExchangeRatesService < ApplicationService
  step :fetch
  step :process
  step :persist

  def fetch(_input)
    ECBExchangeRates::Fetcher.new.call
  end

  def process(input)
    ECBExchangeRates::Processor.new.call(input)
  end

  def persist(input)
    temporary_table = :"exchange_rates_import_#{SecureRandom.hex(4)}"

    DB.transaction(rollback: :reraise) do
      DB.run %(CREATE TEMPORARY TABLE "#{temporary_table}" (LIKE "exchange_rates") ON COMMIT DROP)
      DB.copy_into(temporary_table, data: input, format: :csv)
      DB[:exchange_rates].insert_conflict.insert(DB[temporary_table])
    end

    Right(true)
  rescue Sequel::Error
    Left(:persistence_failed)
  end
end
