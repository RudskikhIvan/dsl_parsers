require "spec_helper"

class TestXmlParser
  include DslParsers::NokogiriXmlParser
end

class TestHtmlParser
  include DslParsers::NokogiriHtmlParser
end


describe 'Parsing' do

  describe 'XML' do

    before do
      @xml = File.read(File.join(File.dirname(__FILE__), '../xml/air_pricing.xml'))
    end

    it 'correct parse 1' do

      parser = Class.new(TestXmlParser) do
        root_path 'PricedItinerary'

        has_one :code, '@CurrencyCode'
        has_one :amount, '@TotalAmount', Integer
        has_many :prices, 'AirItineraryPricingInfo' do
          has_one :total, './/TotalFare/@Amount', Integer
          has_one :total_currency, './/TotalFare/@CurrencyCode'
          has_one :fare, './/BaseFare/@Amount', Integer
          has_one :fare_currency, './/BaseFare/@CurrencyCode'
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

      parser = Class.new(TestXmlParser) do
        root_path 'PricedItinerary'
        has_many :fares, './/TotalFare/@Amount', Integer
        has_many :taxes, './/Taxes/@TotalAmount', Integer
        has_many :passengers, './/PassengerTypeQuantity/@Code'
      end

      res = parser.parse(@xml)

      expect(res).to eq({
        :fares => [80635, 41275, 7875],
        :taxes => [1915, 1915, 0],
        :passengers => ['ADT', 'CNN', 'INF']
      })

    end

    it 'correct parse 3' do
      parser = Class.new(TestXmlParser) do
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

      parser = Class.new(TestXmlParser) do
        root_path 'AirItineraryPricingInfo'
        few true

        has_one :total, './/TotalFare/@Amount', Integer
        has_one :total_currency, './/TotalFare/@CurrencyCode'
        has_one :fare, './/BaseFare/@Amount', Integer
        has_one :fare_currency, './/BaseFare/@CurrencyCode'

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

  describe 'HTML' do
    before do
      @html = File.read(File.join(File.dirname(__FILE__), '../xml/github.html'))
    end

    it 'parse github news' do
      parser = Class.new(TestHtmlParser) do
        has_one :user, '.header-nav-link.name .css-truncate-target'
        has_many :news, '#dashboard .news .alert' do
          has_one :time, :xpath => './/time/@datetime', :type => Time
          has_one :title, '.title', ->(title){ node_to_string(title).strip }
          has_one :message, '.message blockquote', :strip
        end

        def strip(message)
          node_to_string(message).strip
        end
      end

      res = parser.parse(@html)
      expect(res[:user]).to eq 'shredder-rull'
      expect(res[:news].size).to eq 30

      expect(res[:news].first).to eq({
        :time=>Time.parse('2015-02-26 09:10:25 UTC'),
        :title=>"jordimassaguerpla closed pull request rails/rails#17595",
        :message=>"fix #17454: ArgumentError: invalid byte sequence in UTF-8"
      })

      res[:news].each do |n|
        expect(n).to have_hash_like_that({
           :time => Time,
           :title => String,
           :message => String
        })
      end

    end

    it 'parse my repositories in github' do
      parser = Class.new(TestHtmlParser) do
        root_path '#repo_listing li'
        few true

        has_one :name, '.repo'
        has_one :url, :xpath => 'a/@href'
      end

      res = parser.parse(@html)
      expect(res.size).to eq(11)
      res.each do |r|
        expect(r).to have_hash_like_that({
          :name => String,
          :url => String
        })
      end

    end
  end

end