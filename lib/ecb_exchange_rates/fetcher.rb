# frozen_string_literal: true

module ECBExchangeRates
  class Fetcher
    SOURCE_URL       = 'https://sdw.ecb.europa.eu/quickviewexport.do?SERIES_KEY=120.EXR.D.USD.EUR.SP00.A&type=csv'
    VALID_ECB_HEADER = 'ECB reference exchange rate'

    def call(source_url = SOURCE_URL)
      ecb_exchange_rates_csv = Down.open(source_url)

      if check_csv_stream(ecb_exchange_rates_csv)
        Dry::Monads.Right(to_stream(ecb_exchange_rates_csv))
      else
        Dry::Monads.Left(:invalid_csv)
      end
    rescue Down::NotFound, ArgumentError
      Dry::Monads.Left(:not_found)
    rescue Down::Error
      Dry::Monads.Left(:source_failure)
    end

    private

    def to_stream(data)
      Enumerator.new do |yielder|
        yielder << data.gets until data.eof?
      end.lazy
    end

    # NOTE: This check could be more precise but this would be good enough for this assignment
    def check_csv_stream(stream)
      content_type = stream.data.dig(:headers, 'Content-Type')
      return false unless content_type == 'text/csv'
      # Look for the valid header in the first 150 bytes of the stream
      return false unless stream.read(150).include?(VALID_ECB_HEADER)
      stream.rewind
      true
    end
  end
end
