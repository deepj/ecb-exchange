# frozen_string_literal: true

require 'validators/exchange_validator'

class ExchangeService < ApplicationService
  step :validate
  step :convert

  def validate(input)
    input = input.is_a?(Hash) ? input : {}
    validator = ExchangeValidator.(input)
    validator.success? ? Right(validator.output) : Left(validator.messages)
  end

  def convert(input)
    converted_amount = DB[:exchange_rates].where { date <= input[:date].to_s }
                                          .order(Sequel.desc(:date))
                                          .get { round(input[:amount] / rate, 4) }

    if converted_amount
      Right(amount: converted_amount.to_s('F'), date: input[:date].to_s)
    else
      Left("#{input[:amount].to_s('F')} USD cannot be converted because any exchange rate couldn't be found in #{input[:date]}")
    end
  end
end
