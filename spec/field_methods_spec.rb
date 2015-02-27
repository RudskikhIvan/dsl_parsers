require "spec_helper"

class TestParser
  include DslParsers::BaseParser

  def self.default_finder
    :xpath
  end

  def self.available_finders
    [:xpath, :css, :regexp]
  end

end

describe 'has_one methods' do

  it 'build one level map' do
    test_class = Class.new(TestParser) do
      has_one :first_name, 'Users/User/@FirstName'
      has_one :last_name, :css => '#users .user #last_name'
      has_one :age, 'Users/User/Age', Integer
      has_one :birthday, :xpath => 'Users/User/Birthday', :type => Date
    end

    expect(test_class.map.size).to be 4
    expect(test_class.map[:first_name]).to eq({
      :path => 'Users/User/@FirstName',
      :finder_method => :xpath,
      :map => String
    })
    expect(test_class.map[:last_name]).to eq({
      :path => '#users .user #last_name',
      :finder_method => :css,
      :map => String
    })
    expect(test_class.map[:age]).to eq({
      :path => 'Users/User/Age',
      :finder_method => :xpath,
      :map => Integer
    })
    expect(test_class.map[:birthday]).to eq({
      :path => 'Users/User/Birthday',
      :finder_method => :xpath,
      :map => Date
    })
  end

  it 'build some levels map' do
    test_class = Class.new(TestParser) do
      has_one :first_name, 'Parent/@FirstName'
      has_one :document, 'Parent/Document' do
        has_one :code, 'Code'
        has_one :number, 'Number'
      end
      has_many :children, 'Parent/Children' do
        has_one :document, 'Child/Document' do
          has_one :code, 'Code'
          has_one :number, 'Number'
        end
        has_one :first_name, 'Child/@FirstName'
        has_one :age, 'Child/@Age', type: Integer
      end
    end

    expect(test_class.map.size).to be 3

    expect(test_class.map[:first_name]).to eq({
      :path => 'Parent/@FirstName',
      :finder_method => :xpath,
      :map => String
    })

    expect(test_class.map[:document]).to eq({
      :path => 'Parent/Document',
      :finder_method => :xpath,
      :map => {
        :code => {
          :path => 'Code',
          :finder_method => :xpath,
          :map => String
        },
        :number => {
          :path => 'Number',
          :finder_method => :xpath,
          :map => String
        }
      }
    })

    expect(test_class.map[:children]).to eq({
      :path => 'Parent/Children',
      :finder_method => :xpath,
      :many => true,
      :map => {
        :document => {
          :path => 'Child/Document',
          :finder_method => :xpath,
          :map => {
            :code => {
              :path => 'Code',
              :finder_method => :xpath,
              :map => String
            },
            :number => {
              :path => 'Number',
              :finder_method => :xpath,
              :map => String
            }
          }
        },
        :first_name => {
          :path => 'Child/@FirstName',
          :finder_method => :xpath,
          :map => String
        },
        :age => {
          :path => 'Child/@Age',
          :finder_method => :xpath,
          :map => Integer
        }
      }
    })


  end

  it 'build correct map where call has_many with type' do
    test_class = Class.new(TestParser) do
      has_many :fares, './/TotalFare/@Amount', Integer
      has_many :taxes, './/Taxes/@TotalAmount', Integer
      has_many :passengers, './/PassengerTypeQuantity/@Code'
    end

    expect(test_class.map).to eq({
      :fares => {
        :path => './/TotalFare/@Amount',
        :finder_method => :xpath,
        :map => Integer,
        :many=>true
      },
      :taxes => {
        :path => './/Taxes/@TotalAmount',
        :finder_method => :xpath,
        :map => Integer,
        :many=>true
      },
      :passengers => {
        :path => './/PassengerTypeQuantity/@Code',
        :finder_method => :xpath,
        :map => String,
        :many=>true
      }
    })

  end

end

