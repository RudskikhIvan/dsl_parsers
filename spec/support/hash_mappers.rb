require 'hirb'
RSpec::Matchers.define(:have_hash_like_that) do |hash_like_that|

  match do |object|

    object = HashWithIndifferentAccess.new(object) if object.is_a?(Hash)
    get_value = proc{|key| object.is_a?(Hash) ? object[key] : object.send(key) rescue nil }

    @diff_keys = hash_like_that.map do |key, value|
      got_value = get_value.call(key)
      if value.is_a?(Class)
        { key: key, expected: "any of <#{value.name}>", got: "#{got_value}:<#{got_value.class}>" } unless got_value.is_a?(value)
      else
        {key: key, expected: "#{value}:<#{value.class}>", got: "#{got_value}:<#{got_value.class}>"} unless value == got_value
      end
    end.compact

    if @diff_keys.present?
      @msg = Hirb::Helpers::AutoTable.render @diff_keys, fields: [:key, :expected, :got]
    end

    @diff_keys.blank?
  end

  failure_message do |object|
    "#{@msg}"
  end
  failure_message_when_negated do |object|
    "#{@msg}"
  end
end
