# frozen_string_literal: true

ENV['DATABASE_URL'] ||= case ENV['RACK_ENV']
                        when 'test'
                          'postgres://postgres:postgres@localhost:5432/ecb-exchange_test'
                        when 'production'
                          'postgres://postgres:postgres@localhost:5432/ecb-exchange_production'
                        else
                          'postgres://postgres:postgres@localhost:5432/ecb-exchange_development'
                        end

DATABASE_URL = ENV.delete('DATABASE_URL')

DB = Sequel.connect(DATABASE_URL)
DB.loggers << Logger.new($stdout) if ENV['RACK_ENV'] == 'development'
