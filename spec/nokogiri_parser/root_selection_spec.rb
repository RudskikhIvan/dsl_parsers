require "spec_helper"

class TestXmlParser
  include DslParsers::NokogiriXmlParser
end

class TestHtmlParser
  include DslParsers::NokogiriHtmlParser
end


describe 'Root selection' do

  describe 'XML' do

    before do
      @xml = File.read(File.join(File.dirname(__FILE__), '../xml/air_pricing.xml'))
    end

    let(:parser) { TestXmlParser.new }

    it 'select correct root tag' do
      root = parser.select_root(@xml)
      expect(root.size).to eq(1)
      expect(root.first.name).to eq 'PriceQuote'

      TestXmlParser.send(:root_path, 'PriceQuote')
      root = parser.select_root(@xml)
      expect(root.size).to eq(1)
      expect(root.first.name).to eq 'PriceQuote'

      TestXmlParser.send(:root_path, 'PriceQuote/MiscInformation')
      root = parser.select_root(@xml)
      expect(root.size).to eq(1)
      expect(root.first.name).to eq 'MiscInformation'

      TestXmlParser.send(:root_path, 'PricedItinerary')
      root = parser.select_root(@xml)
      expect(root.size).to eq(1)
      expect(root.first.name).to eq 'PricedItinerary'

      TestXmlParser.send(:root_path, 'AirItineraryPricingInfo')
      root = parser.select_root(@xml)
      expect(root.size).to eq(3)
      expect(root.first.name).to eq 'AirItineraryPricingInfo'

      TestXmlParser.send(:root_path, 'PricedItinerary/AirItineraryPricingInfo')
      root = parser.select_root(@xml)
      expect(root.size).to eq(3)
      expect(root.first.name).to eq 'AirItineraryPricingInfo'

    end

  end

  describe 'HTML' do
    before do
      @html = File.read(File.join(File.dirname(__FILE__), '../xml/github.html'))
    end

    let(:parser) { TestHtmlParser.new }

    it 'select correct root tag by css' do
      root = parser.select_root(@html)
      expect(root.size).to eq(1)
      expect(root.first.name).to eq 'html'

      TestHtmlParser.send(:root_path, 'body')
      root = parser.select_root(@html)
      expect(root.size).to eq(1)
      expect(root.first.name).to eq 'body'

      TestHtmlParser.send(:root_path, '.header-logged-in')
      root = parser.select_root(@html)
      expect(root.size).to eq(1)
      expect(root.first.attr('class')).to include 'header-logged-in'

      TestHtmlParser.send(:root_path, '.header-logged-in .header-nav-item')
      root = parser.select_root(@html)
      expect(root.first.attr('class')).to include 'header-nav-item'

      TestHtmlParser.send(:root_path, 'body #site-container')
      root = parser.select_root(@html)
      expect(root.first.attr('id')).to eq 'site-container'

    end

  end

end