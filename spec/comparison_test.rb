require 'benchmark/ips'
require 'spec_helper'

describe 'Comparison' do

  let(:xml){ File.read(File.join(File.dirname(__FILE__), 'xml/air_pricing.xml')) }

  it 'show parsing time from different parsers' do

    block = Proc.new do

      has_one :amount, 'PricedItinerary/@TotalAmount', Integer
      has_one  :currency_code, 'PricedItinerary/@CurrencyCode'
      has_one  :validating_carrier, 'MiscInformation/HeaderInformation/ValidatingCarrier/@Code'
      has_many :pricings, 'PricedItinerary/AirItineraryPricingInfo' do
        has_one :passenger_type, 'PassengerTypeQuantity/@Code'
        has_one :passenger_count, 'PassengerTypeQuantity/@Quantity', Integer
        has_one :fare_amount, 'ItinTotalFare/BaseFare/@Amount', Integer
        has_one :fare_currency, 'ItinTotalFare/BaseFare/@CurrencyCode'
        has_one :fare_equiv_amount, 'ItinTotalFare/EquivFare/@Amount', Integer
        has_one :fare_equiv_currency, 'ItinTotalFare/EquivFare/@CurrencyCode'
        has_one :taxes_amount, 'ItinTotalFare/Taxes/@TotalAmount', Integer
        has_one :total_amount, 'ItinTotalFare/TotalFare/@Amount', Integer
      end
      has_many :marketing_carriers, '*/PTC_FareBreakdown/FareBasis/@FilingCarrier'
      has_many :texts, 'MiscInformation/HeaderInformation/Text'

    end

    nokogiri_parser = Class.new(DslParsers::NokogiriXmlParser::Base, &block)
    ox_parser = Class.new(DslParsers::OxXmlParser::Base, &block)

    Benchmark.ips do |x|
      x.report('nokogiri'){ nokogiri_parser.parse(xml) }
      x.report('ox'){ ox_parser.parse(xml) }
    end

  end

end