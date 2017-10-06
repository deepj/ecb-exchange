# frozen_string_literal: true

require_relative 'boot'

require 'roda'

require 'services/exchange_service'

class App < Roda
  plugin :json
  plugin :json_parser
  plugin :indifferent_params
  plugin :not_allowed
  plugin :not_found

  route do |r|
    r.post 'exchange' do
      exchange_service = ExchangeService.new

      exchange_service.call(params) do |result|
        result.success { |value| value }
        result.failure do |error|
          response.status = 422
          { error: error }
        end
      end
    end
  end
end
