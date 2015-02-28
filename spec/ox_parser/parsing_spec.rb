require "spec_helper"


describe 'Parsing' do


  before do
    @xml = File.read(File.join(File.dirname(__FILE__), '../xml/air_pricing.xml'))
  end

  it 'correct parse 1' do

    parser = Class.new(DslParsers::OxXmlParser::Base) do
      root_path 'PricedItinerary'

      has_one :code, '@CurrencyCode'
      has_one :amount, '@TotalAmount', Integer
      has_many :prices, 'AirItineraryPricingInfo' do
        has_one :total, '*/TotalFare/@Amount', Integer
        has_one :total_currency, '*/TotalFare/@CurrencyCode'
        has_one :fare, '*/BaseFare/@Amount', Integer
        has_one :fare_currency, '*/BaseFare/@CurrencyCode'
      end
    end

    res = parser.parse(@xml)

    expect(res).to have_hash_like_that({
      :code => 'RUB',
      :amount => 129785,
      :prices => Array
    })

    expect(res[:prices].size).to eq(3)
    res[:prices].each do |r|
      expect(r).to have_hash_like_that({
        :total_currency => 'RUB',
        :fare_currency => 'EUR',
        :total => Integer,
        :fare => Integer
      })
    end

  end

  it 'correct parse 2' do

    parser = Class.new(DslParsers::OxXmlParser::Base) do
      root_path 'PricedItinerary'
      has_many :fares, '*/TotalFare/@Amount', Integer
      has_many :taxes, '*/Taxes/@TotalAmount', Integer
      has_many :passengers, '*/PassengerTypeQuantity/@Code'
    end

    res = parser.parse(@xml)

    expect(res).to eq({
      :fares => [80635, 41275, 7875],
      :taxes => [1915, 1915, 0],
      :passengers => ['ADT', 'CNN', 'INF']
    })

  end

  it 'correct parse 3' do
    parser = Class.new(DslParsers::OxXmlParser::Base) do
      include DslParsers::NokogiriXmlParser
      root_path 'ItinTotalFare'

      has_one :fare, 'TotalFare/@Amount', Integer
      has_one :fare_currency, 'TotalFare/@CurrencyCode'
      has_one :taxes, 'Taxes/@TotalAmount', Integer
    end

    res = parser.parse(@xml)

    expect(res).to eq({
      fare: 80635,
      fare_currency: 'RUB',
      taxes: 1915
    })
  end

  it 'parse many root elements' do

    parser = Class.new(DslParsers::OxXmlParser::Base) do
      root_path 'AirItineraryPricingInfo'
      few true

      has_one :total, '*/TotalFare/@Amount', Integer
      has_one :total_currency, '*/TotalFare/@CurrencyCode'
      has_one :fare, '*/BaseFare/@Amount', Integer
      has_one :fare_currency, '*/BaseFare/@CurrencyCode'

    end

    res = parser.parse(@xml)

    expect(res.size).to eq(3)

    res.each do |r|
      expect(r).to have_hash_like_that({
        :total_currency => 'RUB',
        :fare_currency => 'EUR',
        :total => Integer,
        :fare => Integer
      })
    end

  end

end