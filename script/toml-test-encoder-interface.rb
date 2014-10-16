#!/usr/bin/env ruby
#
# This is an interface for: https://github.com/BurntSushi/toml-test

require 'json'
require '../lib/toml'

def toml_test_to_ruby(toml_obj)
  if toml_obj.kind_of?(Array)
    return toml_obj.map do |value|
      value = toml_test_to_ruby(value)
    end
  elsif toml_obj.has_key?("type")
    case toml_obj["type"]
    when "string"
      return toml_obj["value"]
    when "integer"
      return toml_obj["value"].to_i
    when "float"
      return toml_obj["value"].to_f
    when "datetime"
      return DateTime.iso8601(toml_obj["value"])
    when "bool"
      case toml_obj["value"]
      when "true"
        return true
      when "false"
        return false
      end
    when "array"
      return toml_test_to_ruby(toml_obj["value"])
    end
  else
    obj = {}
    toml_obj.each do |key, value|
      obj[key] = toml_test_to_ruby(value)
    end
    obj
  end
end

obj = toml_test_to_ruby(JSON.load(ARGF.read))

print TOML::Generator.new(obj).body
