# frozen_string_literal: true

require 'support/shared_contexts/exchange_rates_with_weekdays_context'

RSpec.describe App, type: :request do
  include_context 'exchange rates with weekdays'

  describe 'POST /exchange' do
    subject(:request) do
      header 'Content-Type', 'application/json'
      post '/exchange', params.to_json
    end

    let(:params) { { amount: 120, date: '2011-03-05' } }

    before { request }

    it 'returns the correct response' do
      expect(last_response).to have_status_code(200)
      expect(last_response).to have_content_type('application/json')
      expect(last_response).to match_json_schema('exchange')
    end

    it 'returns a newly created user response' do
      expect(json_response).to include(amount: '85.9784', date: '2011-03-05')
    end

    context 'when params are not valid' do
      let(:params) { {} }

      it 'returns the error response' do
        expect(last_response).to have_status_code(422)
        expect(last_response).to have_content_type('application/json')
        expect(json_response).to include(error:
          a_hash_including(date: [matching('is missing')],
                           amount: [matching('is missing'), matching('must be greater than 0')]))
      end
    end
  end
end
