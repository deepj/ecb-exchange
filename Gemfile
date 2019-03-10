# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.1'

gem 'puma', '3.12.0'

# Roda
gem 'roda', '3.17.0'

# Dry
gem 'dry-monads',      '1.2.0'
gem 'dry-validation',  '0.13.0'
gem 'dry-transaction', '0.13.0'

# DB
gem 'pg',        '1.1.4'
gem 'sequel',    '5.18.0'
gem 'sequel_pg', '1.12.0', require: 'sequel'

# Utils
gem 'down', '4.8.0'
gem 'rake', '12.3.2'

group :development do
  gem 'rubocop', '0.65.0', require: false
end

group :test do
  gem 'vcr',              '4.0.0'
  gem 'webmock',          '3.5.1'
  gem 'rspec',            '3.8.0'
  gem 'rack-test',        '1.1.0'
  gem 'json-schema',      '2.8.1'
  gem 'database_cleaner', '1.7.0'
end
