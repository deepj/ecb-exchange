# frozen_string_literal: true

require 'dry-struct'

class Error < Dry::Struct
  attribute :amount,        Types::Amount.constrained(gt: 0)
  attribute :currency,      Types::Currency
  attribute :location,      Types::String
  attribute :duration,      Types::String
  attribute :coordinations, Types::Coordinations
end
