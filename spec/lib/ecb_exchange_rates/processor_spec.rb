# frozen_string_literal: true

require 'lib/ecb_exchange_rates/processor'

RSpec.describe ECBExchangeRates::Processor, type: :lib do
  subject(:processor) { described_class.new.call(stream) }

  let(:stream) { csv.each_line.lazy }
  let(:csv) do
    <<~CSV
      Data Source in SDW: null
      ,EXR.D.USD.EUR.SP00.A
      ,"ECB reference exchange rate, US dollar/Euro, 2:15 pm (C.E.T.)"
      Collection:,Average of observations through period (A)
      Period\Unit:,[US dollar ]
      2017-09-01,1.1920
      2017-08-31,1.1825
      2017-08-30,1.1916
      2017-08-29,1.2048
    CSV
  end

  it 'returns a processed stream' do
    expect(processor).to be_success
    expect(processor.value!).to be_a(Enumerator::Lazy)
    expect(processor.value!).to match([
                                        including('2017-09-01,1.1920'),
                                        including('2017-08-31,1.1825'),
                                        including('2017-08-30,1.1916'),
                                        including('2017-08-29,1.2048')
                                      ])
  end

  context 'when there are CSV headers in a stream' do
    it 'removes CSV headers' do
      expect(processor).to be_success
      expect(processor.value!).to be_a(Enumerator::Lazy)
      expect(processor.value!).to match([
                                          including('2017-09-01,1.1920'),
                                          including('2017-08-31,1.1825'),
                                          including('2017-08-30,1.1916'),
                                          including('2017-08-29,1.2048')
                                        ])
    end
  end

  context 'when there are invalid rows in a stream' do
    let(:csv) do
      <<~CSV
        2017-09-01,1.1920
        2017-08-31,1.1825
        2001-01-02,0.9423
        2001-01-01,-
        2000-12-29,0.9305
        2000-12-27,0.9310
        2000-12-26,-
        2000-12-25,-
        2000-12-22,0.9240
        1999-12-31,-
        1999-12-30,1.0046
        1999-12-29,1.0072
      CSV
    end

    it 'removes CSV headers' do
      expect(processor).to be_success
      expect(processor.value!).to be_a(Enumerator::Lazy)
      expect(processor.value!).to match([
                                          including('2017-09-01,1.1920'),
                                          including('2017-08-31,1.1825'),
                                          including('2001-01-02,0.9423'),
                                          including('2000-12-29,0.9305'),
                                          including('2000-12-27,0.9310'),
                                          including('2000-12-22,0.9240')
                                        ])
    end
  end

  context 'when stream processing fails' do
    let(:stream) { '' }

    it 'returns the stream_processing_failed error code' do
      expect(processor).to be_failure
      expect(processor).to eq Failure(:stream_processing_failed)
    end
  end
end
