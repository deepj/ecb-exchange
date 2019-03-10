# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:exchange_rates) do
      Date :date, primary_key: true
      BigDecimal :rate, size: [8, 4]
    end
  end
end
