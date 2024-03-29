# frozen_string_literal: true

module ECBExchangeRates
  class Processor
    include Dry::Monads::Result::Mixin

    ROW_MATCH   = /\A(2\d{3})-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])/.freeze
    INVALID_ROW = /\A(1\d{3})|(-[\r\n]{,2})\z/.freeze

    def call(stream)
      processed_data = stream.drop_while { |line| !line.match?(ROW_MATCH) }
                             .reject     { |line| line.match?(INVALID_ROW) }

      Success(processed_data)
    rescue StandardError
      Failure(:stream_processing_failed)
    end
  end
end
