require "spec_helper"

class TestOxXmlParser
  include DslParsers::OxXmlParser
end


describe 'Root selection' do

  describe 'XML' do

    before do
      @xml = File.read(File.join(File.dirname(__FILE__), '../xml/air_pricing.xml'))
    end

    let(:parser) { TestOxXmlParser.new }

    it 'select correct root tag' do
      root = parser.select_root(@xml)
      expect(root.size).to eq(1)
      expect(root.first.name).to eq 'PriceQuote'

      TestOxXmlParser.send(:root_path, 'MiscInformation/HeaderInformation')
      root = parser.select_root(@xml)
      expect(root.size).to eq(1)
      expect(root.first.name).to eq 'HeaderInformation'

      TestOxXmlParser.send(:root_path, 'PricedItinerary')
      root = parser.select_root(@xml)
      expect(root.size).to eq(1)
      expect(root.first.name).to eq 'PricedItinerary'

      TestOxXmlParser.send(:root_path, 'AirItineraryPricingInfo')
      root = parser.select_root(@xml)
      expect(root.size).to eq(3)
      expect(root.first.name).to eq 'AirItineraryPricingInfo'

      TestOxXmlParser.send(:root_path, 'PricedItinerary/AirItineraryPricingInfo')
      root = parser.select_root(@xml)
      expect(root.size).to eq(3)
      expect(root.first.name).to eq 'AirItineraryPricingInfo'

      TestOxXmlParser.send(:root_path, 'AirItineraryPricingInfo/*/Taxes')
      root = parser.select_root(@xml)
      expect(root.size).to eq(3)
      expect(root.first.name).to eq 'Taxes'

    end

  end

end