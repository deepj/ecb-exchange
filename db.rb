# frozen_string_literal: true

ENV['DATABASE_URL'] ||= case ENV['RACK_ENV']
                        when 'test'
                          'postgres:///leadfeeder-martin-assignment_test?user=mh-assignment'
                        when 'production'
                          'postgres:///leadfeeder-martin-assignment_production?user=mh-assignment'
                        else
                          'postgres:///leadfeeder-martin-assignment_development?user=mh-assignment'
                        end

DB = Sequel.connect(ENV.delete('DATABASE_URL'))
DB.loggers << Logger.new($stdout) if ENV['RACK_ENV'] == 'development'
