# MH Assignment

## Requirements

- Ruby 2.4.1
- Bundler
- PostgreSQL (9.5+)

## Run and test

Setup a database for this prototype using this commands (tested on Mac with installed PostgreSQL 9.6.5 using Homebrew)

```
createuser -U postgres mh
createdb -U postgres -O mh ecb-exchange_development
createdb -U postgres -O mh ecb-exchange_test
```

After then, just run these two commands:

```
bundle exec rake db:migrate
bundle exec rake db:migrate RACK_ENV=test
```

The current ECB exchange rate list can be imported using this rake task:

```
rake import
```

RSpec tests can be run as usual (please, run `bundle exec rake db:migrate RACK_ENV=test` before that)

```
bundle exec rspec
```

In case of API only POST /exchanges is treated against some user mistakes. It's not bullet-proof API implementation.


API can be run:

```
bundle exec rackup
```

Then just call

```
curl -v -XPOST http://localhost:9292/exchange -d '{ "amount": 120.0, "date": "2011-03-05" }' -H "Content-Type: application/json"
```

There is an application console:

```
rake console
```

There is a class for the exchange -> `ExchangeService`

Just call `ExchangeService.new.call(amount: 120, date: '2011-03-15')`

There is also a class for the import -> `ImportExchangeRatesService.new.call(nil)` (NOTE: the `nil` is important)
