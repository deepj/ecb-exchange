# frozen_string_literal: true

require 'validators/exchange_validator'

class ExchangeService < ApplicationService
  step :validate
  step :convert

  def validate(input)
    validator = ExchangeValidator.(amount: input[:amount], date: input[:date])
    validator.success? ? Right(validator.output) : Left(validator.messages)
  end

  def convert(input)
    converted_amount = DB[:exchange_rates].where { date <= input[:date].to_s }
                                          .order(Sequel.desc(:date))
                                          .get { (rate * input[:amount]) }

    if converted_amount
      Right(amount: converted_amount.to_s('F'), date: input[:date].to_s)
    else
      Left("#{input[:amount].to_s('F')} USD cannot be converted because any exchange rate couldn't be found in #{input[:date]}")
    end
  end
end
