# DslParsers

Ruby DslParsers allows to build XML parsers in DSL style

## Installation

Add this line to your application's Gemfile:

``` ruby
gem "dsl_parsers", git: "https://github.com/shredder-rull/dsl_parsers.git"
```

And then execute:

``` ruby
$ bundle
```

## Mini documentation

To parse HTML use DslParsers::NokogiriHtmlParser

To parse XML using xpath or css selectors use DslParsers::NokogiriXmlParser

To faster parsing XML use DslParsers::OxXmlParser. It has specific selector, more https://github.com/ohler55/ox/blob/master/lib/ox/element.rb

For more information You may look rspec tests

## Example

xml:
``` xml
<AirItineraryPricingInfo>
  <FareCalculation>
   <Text>MOW SU LON2503.03NUC2503.03END ROE0.767069</Text>
  </FareCalculation>
  <ItinTotalFare>
   <BaseFare Amount="1920.00" CurrencyCode="EUR"/>
   <EquivFare Amount="78720" CurrencyCode="RUB"/>
   <TotalFare Amount="80635" CurrencyCode="RUB"/>
   <Taxes TotalAmount="1915" CurrencyCode="RUB">
  </ItinTotalFare>
  <PassengerTypeQuantity Code="ADT" Quantity="1"/>
  <PTC_FareBreakdown>
  </PTC_FareBreakdown>
</AirItineraryPricingInfo>
```

parser:
``` ruby
class ExampleParser
  include DslParsers::NokogiriXmlParser
  root_path 'ItinTotalFare'

  has_one :fare, 'TotalFare/@Amount', Integer
  has_one :fare_currency, 'TotalFare/@CurrencyCode'
  has_one :taxes, 'Taxes/@TotalAmount', Integer
  has_one :taxes_currency, 'Taxes/@CurrencyCode'
end

ExampleParser.parse(xml)
```

result:
``` ruby
{
  fare: 80635,
  fare_currency: 'RUB',
  taxes: 1915,
  taxes_currency: 'RUB'
}
```
