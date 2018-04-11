require "spec_helper"

describe 'Enum' do
  it 'parses given array of symbols' do
    choices = %i[accepted refused]
    expect(DslParsers::Enum(choices).parse('Refused')).to eq(:refused)
  end

  it 'can respect case' do
    choices = %i[accepted refused]
    expect(DslParsers::Enum(choices, Regexp::EXTENDED).parse('Refused')).to be_nil
  end

  it 'parses given array of symbols' do
    choices = {
      /foo/i => :foo,
      proc { true } => :any,
    }
    expect(DslParsers::Enum(choices).parse('WTF')).to eq(:any)

    # wont work if hash is not ordered (ruby1.8 etc)
    expect(DslParsers::Enum(choices).parse('FOO')).to eq(:foo)
  end

  it 'respects forced order via array' do
    choices = [
      [/foo/i, :foo],
      [/foobar/i, :foobar],
    ]
    expect(DslParsers::Enum(choices).parse('FOOBAR')).to eq(:foo)
    expect(DslParsers::Enum(choices).parse('FOO')).to eq(:foo)
  end
end
