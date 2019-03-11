# frozen_string_literal: true

require 'validators/exchange_validator'

class ExchangeService
  include Dry::Transaction

  step :validate
  step :convert

  def validate(input)
    input = input.is_a?(Hash) ? input : {}

    ExchangeValidator.(input).to_monad
  end

  def convert(input)
    converted_amount = DB[:exchange_rates].where { date <= input[:date].to_s }
                                          .order(Sequel.desc(:date))
                                          .get { round(input[:amount] / rate, 4) }

    if converted_amount
      Success(amount: converted_amount.to_s('F'), date: input[:date].to_s)
    else
      Failure("#{input[:amount].to_s('F')} USD cannot be converted because any exchange rate couldn't be found in #{input[:date]}")
    end
  end
end
