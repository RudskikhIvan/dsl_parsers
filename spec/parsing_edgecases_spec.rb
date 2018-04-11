require "spec_helper"


describe 'Parsing edge cases' do
  describe 'toplevel root tag' do
    before do
      @xml = '<response><status>Refused</status></response>'
    end

    [DslParsers::OxXmlParser::Base, DslParsers::NokogiriXmlParser::Base].each do |klass|
      it "correct parses to nil with #{klass}" do
        parser = Class.new(klass) do
          root_path 'response'
          has_one :status, 'status'
        end

        res = parser.parse(@xml)
        expect(res).to eq({ status: 'Refused' })
      end
    end
  end

  describe 'self-closing tags' do
    before do
      @xml = '<isbn />'
    end

    [DslParsers::OxXmlParser::Base, DslParsers::NokogiriXmlParser::Base].each do |klass|
      it "correct parses to nil with #{klass}" do
        parser = Class.new(klass) do
          has_one :isbn, 'isbn'
        end

        res = parser.parse(@xml)
        expect(res).to eq({ isbn: nil })
      end
    end
  end
end
