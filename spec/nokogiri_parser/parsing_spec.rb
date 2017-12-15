require "spec_helper"

class TestXmlParser
  include DslParsers::NokogiriXmlParser
end

class TestHtmlParser
  include DslParsers::NokogiriHtmlParser
end


describe 'Parsing' do
  describe 'XML' do
    let(:xml) { File.read(File.join(File.dirname(__FILE__), '../xml/air_pricing.xml')) }

    subject { parser.parse(xml) }

    describe 'Nested elements' do
      let(:parser) do
        Class.new(TestXmlParser) do
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
      end

      it 'parses xml with nested structure' do
        expect(subject).to have_hash_like_that({
          :code => 'RUB',
          :amount => 129785,
          :prices => Array
        })

        expect(subject[:prices].size).to eq(3)

        expect(subject[:prices]).to all(have_hash_like_that({
          :total_currency => 'RUB',
          :fare_currency => 'EUR',
          :total => Integer,
          :fare => Integer
        }))
      end
    end


    describe 'Array values' do
      let(:parser) {
        Class.new(TestXmlParser) do
          root_path 'PricedItinerary'
          has_many :fares, './/TotalFare/@Amount', Integer
          has_many :taxes, './/Taxes/@TotalAmount', Integer
          has_many :passengers, './/PassengerTypeQuantity/@Code'
        end
      }

      it 'returns values as array' do
        expect(subject).to eq({
          :fares => [80635, 41275, 7875],
          :taxes => [1915, 1915, 0],
          :passengers => ['ADT', 'CNN', 'INF']
        })
      end
    end


    describe 'Many' do
      let(:parser) do
        Class.new(TestXmlParser) do
          root_path 'AirItineraryPricingInfo'
          few true

          has_one :total, './/TotalFare/@Amount', Integer
          has_one :total_currency, './/TotalFare/@CurrencyCode'
          has_one :fare, './/BaseFare/@Amount', Integer
          has_one :fare_currency, './/BaseFare/@CurrencyCode'

        end
      end

      it 'parse many root elements' do
        expect(subject.size).to eq(3)

        expect(subject).to all(have_hash_like_that({
          :total_currency => 'RUB',
          :fare_currency => 'EUR',
          :total => Integer,
          :fare => Integer
        }))
      end
    end

    describe 'Parser as type' do
      context 'has_one' do
        let(:parser) do
          sub_parser = Class.new(TestXmlParser) do
            root_path 'Tax'
            has_one :amount, '@Amount', Float
            has_one :code, '@TaxCode'
          end

          Class.new(TestXmlParser) do
            root_path 'AirItineraryPricingInfo'
            has_one :total, './/TotalFare/@Amount', Integer
            has_one :total_currency, './/TotalFare/@CurrencyCode'
            has_one :tax, './/Taxes/Tax', sub_parser
          end
        end

        it 'returns value as subparser result' do
          expect(subject[:tax]).to have_hash_like_that({
            amount: Float,
            code: String
          })
        end
      end

      context 'has many' do
        let(:parser) do
          sub_parser = Class.new(TestXmlParser) do
            root_path 'Tax'
            has_one :amount, '@Amount', Float
            has_one :code, '@TaxCode'
          end

          Class.new(TestXmlParser) do
            root_path 'AirItineraryPricingInfo'
            has_one :total, './/TotalFare/@Amount', Integer
            has_one :total_currency, './/TotalFare/@CurrencyCode'
            has_many :taxes, './/Taxes/Tax', sub_parser
          end
        end

        it 'returns value as subparser result' do
          expect(subject[:taxes].size).to eq(3)
          expect(subject[:taxes]).to all have_hash_like_that({
            amount: Float,
            code: String
          })
        end
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
          time: Time,
          title: String,
          message: String
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