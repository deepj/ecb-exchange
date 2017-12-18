# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.5.0'

gem 'puma', '3.11.0'

# Roda
gem 'roda', '3.3.0'

# Dry
gem 'dry-validation', ' 0.11.1'
gem 'dry-transaction', '0.10.2'

# DB
gem 'pg',        '0.21.0'
gem 'sequel',    '5.3.0'
gem 'sequel_pg', '1.8.1', require: 'sequel'

# Utils
gem 'down', '4.1.1'

group :development do
  gem 'rubocop', '0.52.0', require: false
  gem 'rufo',    '0.2.0',  require: false
end

group :test do
  gem 'vcr',              '4.0.0'
  gem 'webmock',          '3.1.1'
  gem 'rspec',            '3.7.0'
  gem 'rack-test',        '0.8.2'
  gem 'json-schema',      '2.8.0'
  gem 'database_cleaner', '1.6.2'
end
