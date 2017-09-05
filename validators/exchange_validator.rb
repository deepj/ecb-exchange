# frozen_string_literal: true

ExchangeValidator = Dry::Validation.Form do
  configure do
    option :date_since, 2000

    def self.messages
      super.merge(
        en: {
          errors: {
            date_since?: 'must be greater',
            date_in_future?: 'cannot be in the future'
          }
        }
      )
    end
  end

  required(:date).filled(:date?)
  required(:amount).filled(:decimal?, gt?: 0)

  validate(date_since?: :date) do |date|
    date.year >= date_since
  end

  validate(date_in_future?: :date) do |date|
    date <= Date.today
  end
end
