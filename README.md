# ECB Exchange

This application is a simple "microservice" based on Roda, Sequel and dry-rb gems. For detailed description application, read [ASSIGNMENT.md](ASSIGNMENT.md).

## Requirements

- Ruby 2.6.1
- Bundler
- PostgreSQL (9.6+)
- Docker (optional)

## Setup for local development

Setup a database using the following commands (tested on Mac with installed PostgreSQL 11.2 via Homebrew)
As a default user is expected default **postgres** user. You can skip these steps by running `bin/local-setup`.


```
createdb -U postgres ecb-exchange_development
createdb -U postgress ecb-exchange_test
```

After then, just run these two commands:

```
bundle exec rake db:migrate
bundle exec rake db:migrate RACK_ENV=test
```

The current ECB exchange rate list can be imported using this rake task:

```
bundle exec rake import
```

## Run and test locally

API server can be run (make sure you run `bundle install` before that):

```
bundle exec rackup
```

The server is running on the local 9292 PORT by default. There is only one endpoint available `POST /exchange`. It requires a message in a JSON message containing two params `amount` (decimal) and `date` (date in YYYY-MM-DD format).

For testing, you can try the following request

```
curl -v http://localhost:9292/exchange -d '{ "amount": 120.0, "date": "2011-03-05" }' -H "Content-Type: application/json"
```

There is an application console:

```
rake console
```

There is also a class for the exchange -> `ExchangeService`. In the console, just call `ExchangeService.new.(amount: 120, date: '2011-03-15')`.

For import, use `ImportExchangeRatesService.new.()`

## Docker

The application is dockerized which is suitable for running on the production environment.

Build Docker image:

```
bin/build-docker
```

Run the application

```
docker-compose up
```

## Specs

RSpec tests can be run as usual (please, make sure you run `bundle exec rake db:migrate RACK_ENV=test` before that)

```
bundle exec rspec
```

# Prototype

The first iteration of application is captured in `prototype.rb`.
