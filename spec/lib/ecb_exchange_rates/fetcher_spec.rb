# frozen_string_literal: true

require 'lib/ecb_exchange_rates/fetcher'

RSpec.describe ECBExchangeRates::Fetcher, vcr: { cassette_name: 'ecb-exchange' }, type: :lib do
  subject(:stream) { fetcher.call }

  let(:fetcher) { described_class.new }

  it 'returns CSV stream' do
    expect(stream).to be_success
    expect(stream.value).to be_a(Enumerator::Lazy)
    expect(stream.value.first).to include('Data Source in SDW: null')
  end

  context 'when the source url is invalid' do
    subject(:stream) { described_class.new.call(nil) }

    it 'returns the not_found error code' do
      expect(stream).to be_failure
      expect(stream.value).to eq(:not_found)
    end
  end

  context 'when the source url cannot be found', vcr: { cassette_name: 'ecb-exchange-invalid-url' } do
    subject(:stream) { described_class.new.call('https://sdw.ecb.europa.eu/quickvieort.do') }

    it 'returns the not_found error code' do
      expect(stream).to be_failure
      expect(stream.value).to eq(:not_found)
    end
  end

  context 'when there is a connection issue on the exchange rates' do
    before do
      allow(Down).to receive(:open).and_raise(Down::Error)
    end

    it 'returns the source_failure error code' do
      expect(stream).to be_failure
      expect(stream.value).to eq(:source_failure)
    end
  end

  context 'when csv is invalid' do
    context 'when content type is wrong' do
      before { WebMock.stub_request(:get, described_class::SOURCE_URL).to_return(headers: { 'Content-Type': 'wrong/csv' }) }

      it 'returns the invalid_csv error code' do
        expect(stream).to be_failure
        expect(stream.value).to eq(:invalid_csv)
      end
    end

    context 'when csv content is not in the good format' do
      before { WebMock.stub_request(:get, described_class::SOURCE_URL).to_return(body: 'wrong content') }

      it 'returns the invalid_csv error code' do
        expect(stream).to be_failure
        expect(stream.value).to eq(:invalid_csv)
      end
    end
  end
end
