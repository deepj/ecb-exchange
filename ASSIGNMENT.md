# Assignment

## Introduction

European Central Bank provides daily exchange rates for converting US Dollars to Euros. The CSV file for up-to-date exchange rates can be downloaded from:

http://sdw.ecb.europa.eu/quickviewexport.do?SERIES_KEY=120.EXR.D.USD.EUR.SP00.A&type=csv

The file looks roughly like below. (The first number here denotes line number, not in actual file).

```
Data Source in SDW: null
,EXR.D.USD.EUR.SP00.A
,"ECB reference exchange rate, US dollar/Euro, 2:15 pm (C.E.T.)"
Collection:,Average of observations through period (A)
Period\Unit:,[US dollar ]
2016-08-18,1.1321
2016-08-17,1.1276
2016-08-16,1.1295
2016-08-15,1.1180
2016-08-12,1.1158
2016-08-11,1.1153
2016-08-10,1.1184
```

Build an utility that can be used to convert an USD value to Euros on any date since year 2000.
To do this you should:

1. Have the application download, parse and store the exchange rates to a database
2. Have a class to handle conversion of a USD value - date pair to Euro value.
   E.g. ExchangeRateConverter.convert(120, '2011-03-05')

Should return what 120 USD was in euros on March 5, 2011. Note that the ECB file only includes days
when they had agreed on the exchange rates - these are typically non-holiday weekdays. To convert values
on weekends and holidays you should use the previous available exchange rate.

## Specs

* Build the assignment in Ruby. You can use Rails, but it is not required.
* You can use any database to store the exchange rates. Choose something sensible and
suitable.
* Include an easy way to download and update the latest values. For example a rake task.
* Make the updating procedure idempotent. Eg. such that it can be ran multiple times
without it being destructive or adding duplicate records.
* Write tests preferably with RSpec.
