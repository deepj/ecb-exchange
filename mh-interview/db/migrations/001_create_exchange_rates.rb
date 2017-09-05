# frozen_string_literal: true

Sequel.migration do
  change do
    create_table?(:exchange_rates) do
      primary_key :date, type: :Date
      BigDecimal :rate, size: [8, 4]
    end
  end
end
