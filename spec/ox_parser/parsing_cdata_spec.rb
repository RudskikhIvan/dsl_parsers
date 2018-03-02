require "spec_helper"


describe 'Parsing' do

  before do
    @xml = File.read(File.join(File.dirname(__FILE__), '../xml/advert.xml'))
  end

  it 'correct parses cdata' do

    parser = Class.new(DslParsers::OxXmlParser::Base) do
      has_one :sku, 'sku'
      has_many :comments, 'comment'
    end

    res = parser.parse(@xml)
    expect(res).to eq({
      sku: 'AA088-FR',
      comments: ['one', 'two']
    })

  end
end