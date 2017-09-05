# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.4.1'

gem 'puma', '3.10.0'

# Roda
gem 'roda', '2.29.0'

# Dry
gem 'dry-validation', ' 0.11.0'
gem 'dry-transaction', '0.10.2'

# DB
gem 'pg',        '0.21.0'
gem 'sequel',    '5.0.0'
gem 'sequel_pg', '1.7.1', require: 'sequel'

# Utils
gem 'down',      '4.1.0'

group :development do
  gem 'rubocop', '0.49.1', require: false
  gem 'rufo',    '0.1.0',  require: false
end

group :test do
  gem 'vcr',              '3.0.3'
  gem 'webmock',          '3.0.1'
  gem 'rspec',            '3.6.0'
  gem 'rack-test',        '0.7.0'
  gem 'json-schema',      '2.8.0'
  gem 'database_cleaner', '1.6.1'
end
