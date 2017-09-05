# frozen_string_literal: true

RSpec.shared_context 'exchange rates with weekdays' do
  let!(:exchange_rates_seed) do
    DB[:exchange_rates].insert(rate: 1.3898, date: '2011-03-08')
    DB[:exchange_rates].insert(rate: 1.4028, date: '2011-03-07')
    DB[:exchange_rates].insert(rate: 1.3957, date: '2011-03-04')
    DB[:exchange_rates].insert(rate: 1.3850, date: '2011-03-03')
    DB[:exchange_rates].insert(rate: 1.3809, date: '2011-03-02')
  end
end
