# frozen_string_literal: true

require 'validators/exchange_validator'

RSpec.describe ExchangeValidator, type: :validator do
  subject(:validator) { described_class }

  context 'when params are valid' do
    it 'passes' do
      expect(validator.(amount: '120',             date: '2011-03-05')).to be_success
      expect(validator.(amount: 120,               date: '2011-03-05')).to be_success
      expect(validator.(amount: 120.0,             date: '2011-03-05')).to be_success
      expect(validator.(amount: '120.0',           date: '2011-03-05')).to be_success
      expect(validator.(amount: BigDecimal('120'), date: '2011-03-05')).to be_success
    end
  end

  context 'when params are invalid' do
    it 'fails with error message' do
      expect(validator.(amount: 120, date: '2099-03-05').messages).to include(date: [matching('cannot be in the future')])
      expect(validator.(amount: 120, date: '1999-03-05').messages).to include(date: [matching('must be greater')])
      expect(validator.(amount: 120, date: '').messages).to           include(date: [matching('must be filled')])
      expect(validator.(amount: 120, date: nil).messages).to          include(date: [matching('must be filled')])

      expect(validator.(amount: -120, date: '2011-03-05').messages).to include(amount: [matching('must be greater than 0')])
      expect(validator.(amount: '',  date: '2011-03-05').messages).to  include(amount: [matching('must be filled'),
                                                                                        matching('must be greater than 0')])
      expect(validator.(amount: nil, date: '2011-03-05').messages).to  include(amount: [matching('must be filled'),
                                                                                        matching('must be greater than 0')])
      expect(validator.(amount: '-', date: '1999-03-05').messages).to  include(amount: [matching('must be a decimal'),
                                                                                        matching('must be greater than 0')])
      expect(validator.({}).messages).to include(amount: [matching('is missing'), matching('must be greater than 0')],
                                                 date: [matching('is missing')])
    end
  end
end
