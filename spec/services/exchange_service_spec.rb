# frozen_string_literal: true

require 'services/exchange_service'
require_relative '../support/shared_contexts/exchange_rates_with_weekdays_context'

RSpec.describe ExchangeService, type: :service do
  include_context 'exchange rates with weekdays'

  subject(:service) { described_class.new.call(params) }

  let(:params) { { amount: '120', date: '2011-03-05' } }

  it 'returns a given exchanged amount for given date' do
    expect(service).to be_success
    expect(service.value).to include(amount: '167.484', date: '2011-03-05')
  end

  context 'when params are invalid' do
    let(:params)               { { amount: '120', date: '1999-03-05' } }
    let!(:exchange_rates_seed) {}

    it 'returns an error validation message' do
      expect(service).to be_failure
      expect(service.value).to include(date: [matching('must be greater')])
    end
  end

  context 'when any exchange rate is not found' do
    let(:params) { { amount: '120', date: '2011-03-01' } }

    it 'returns an error validation message' do
      expect(service).to be_failure
      expect(service.value).to eq("120.0 USD cannot be converted because any exchange rate couldn't be found in 2011-03-01")
    end
  end
end
