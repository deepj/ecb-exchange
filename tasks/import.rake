# frozen_string_literal: true

require 'services/import_exchange_rates_service'

desc 'Import the latest ECB exchange rates'
task :import do
  DB.loggers.clear # Disable annoying logging Sequel commands into the console

  import_exchange_rates_service = ImportExchangeRatesService.new
  import_exchange_rates_service.call(nil) do |result|
    result.success { puts 'ECB exchange rates have been imported.' }
    result.failure { |value| puts "Import has been unsuccessful. Code :#{value}" }
  end
end
