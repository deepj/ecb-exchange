# frozen_string_literal: true

ENV['DATABASE_URL'] ||= case ENV['RACK_ENV']
                        when 'test'
                          'postgres:///ecb-exchange_test?user=mh'
                        when 'production'
                          'postgres:///ecb-exchange_production?user=mh'
                        else
                          'postgres:///ecb-exchange_development?user=mh'
                        end

DB = Sequel.connect(ENV.delete('DATABASE_URL'))
DB.loggers << Logger.new($stdout) if ENV['RACK_ENV'] == 'development'
