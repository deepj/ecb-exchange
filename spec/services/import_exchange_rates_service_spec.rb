# frozen_string_literal: true

require 'services/import_exchange_rates_service'

RSpec.describe ImportExchangeRatesService, type: :service do
  subject(:service) { described_class.new.call() }

  let(:fake_csv_stream) do
    <<~CSV.each_line.lazy
      Data Source in SDW: null
      ,EXR.D.USD.EUR.SP00.A
      ,"ECB reference exchange rate, US dollar/Euro, 2:15 pm (C.E.T.)"
      Collection:,Average of observations through period (A)
      Period\Unit:,[US dollar ]
      2017-09-01,1.1920
      2017-08-31,1.1825
      2017-08-30,1.1916
      2011-03-07,1.4028
      2011-03-04,1.3957
      2011-03-03,1.3850
      2002-01-02,0.9038
      2002-01-01,-
      2001-12-31,-
      2001-12-28,0.8813
      2001-12-27,0.8823
      2001-12-26,-
      2001-12-25,-
      2001-12-24,0.8798
      1999-12-31,-
      1999-12-30,1.0046
    CSV
  end

  before { allow_any_instance_of(described_class).to receive(:fetch).and_return(Dry::Monads.Success(fake_csv_stream)) }

  it 'imports ECB exchange rates successfully' do
    expect { service }.to change { DB[:exchange_rates].count }.from(0).to(10)
    expect(service).to be_success
    expect(service.value!).to be true
  end

  it 'does not duplicite exchange rates' do
    expect(service).to be_success
    expect { service }.not_to change { DB[:exchange_rates].count }
    expect(DB[:exchange_rates].all).to match([
                                               a_hash_including(date: Date.parse('2017-09-01'), rate: BigDecimal('1.1920')),
                                               a_hash_including(date: Date.parse('2017-08-31'), rate: BigDecimal('1.1825')),
                                               a_hash_including(date: Date.parse('2017-08-30'), rate: BigDecimal('1.1916')),
                                               a_hash_including(date: Date.parse('2011-03-07'), rate: BigDecimal('1.4028')),
                                               a_hash_including(date: Date.parse('2011-03-04'), rate: BigDecimal('1.3957')),
                                               a_hash_including(date: Date.parse('2011-03-03'), rate: BigDecimal('1.3850')),
                                               a_hash_including(date: Date.parse('2002-01-02'), rate: BigDecimal('0.9038')),
                                               a_hash_including(date: Date.parse('2001-12-28'), rate: BigDecimal('0.8813')),
                                               a_hash_including(date: Date.parse('2001-12-27'), rate: BigDecimal('0.8823')),
                                               a_hash_including(date: Date.parse('2001-12-24'), rate: BigDecimal('0.8798'))
                                             ])
  end

  context 'when there are already exchange rates' do
    subject(:service)         { described_class.new }
    subject(:another_service) { described_class.new }

    let(:another_fake_csv_stream) do
      <<~CSV.each_line.lazy
        2017-09-01,1.2920
        2017-08-31,1.2825
        2017-08-30,1.2916
        2011-03-07,1.5028
        2011-03-04,1.4957
        2011-03-03,1.4850
        2002-01-02,1.0038
        2001-12-28,0.9813
        2001-12-27,0.9823
        2001-12-24,0.9798
      CSV
    end

    before do
      allow(service).to         receive(:fetch).and_return(Success(fake_csv_stream))
      allow(another_service).to receive(:fetch).and_return(Success(another_fake_csv_stream))
    end

    it 'does not allow to replace them by new ones' do
      expect { service.call }.to change { DB[:exchange_rates].count }.from(0).to(10)
      expect { service.call }.not_to change { DB[:exchange_rates].all }

      expect(DB[:exchange_rates].all).not_to contain_exactly(
        a_hash_including(date: Date.parse('2017-09-01'), rate: BigDecimal('1.2920')),
        a_hash_including(date: Date.parse('2017-08-31'), rate: BigDecimal('1.2825')),
        a_hash_including(date: Date.parse('2017-08-30'), rate: BigDecimal('1.2916')),
        a_hash_including(date: Date.parse('2011-03-07'), rate: BigDecimal('1.5028')),
        a_hash_including(date: Date.parse('2011-03-04'), rate: BigDecimal('1.4957')),
        a_hash_including(date: Date.parse('2011-03-03'), rate: BigDecimal('1.4850')),
        a_hash_including(date: Date.parse('2002-01-02'), rate: BigDecimal('1.0038')),
        a_hash_including(date: Date.parse('2001-12-28'), rate: BigDecimal('0.9813')),
        a_hash_including(date: Date.parse('2001-12-27'), rate: BigDecimal('0.9823')),
        a_hash_including(date: Date.parse('2001-12-24'), rate: BigDecimal('0.9798'))
      )
    end
  end

  context 'when persitence fails' do
    before { allow(DB).to receive(:copy_into).and_raise(Sequel::Error) }

    it 'returns persistence_failed error code' do
      expect { service }.not_to change { DB[:exchange_rates].count }
      expect(service).to be_failure
      expect(service).to eq Failure(:persistence_failed)
    end
  end
end
