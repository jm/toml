#!/usr/bin/env ruby
#
# This is an interface for: https://github.com/BurntSushi/toml-test

require 'json'
require '../lib/toml'

# This converts a ruby obj to an obj that can be ran through the json encoder
# to create json for toml-test.
def obj_to_toml_test(obj)
  if obj.kind_of?(Hash)
    toml_test = {}
    obj.each do |key, value|
      toml_test[key] = obj_to_toml_test(value)
    end
  elsif obj.kind_of?(Array)
    toml_test = obj.map do |value|
      value = obj_to_toml_test(value)
    end

    unless obj.first.kind_of?(Hash)
      toml_test = {"type" => "array", "value" => toml_test}
    end
  else
    type = obj.class.name.downcase
    value = obj.to_s

    if obj.kind_of?(FalseClass)
      type = "bool"
      value = "false"
    elsif obj.kind_of?(TrueClass)
      type = "bool"
      value = "true"
    elsif obj.kind_of?(DateTime)
      value = obj.to_time.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    elsif obj.kind_of?(Integer)
      type = "integer"
    elsif obj.kind_of?(Float)
      type = "float"
    end

    toml_test = {"type" => type, "value" => value}
  end

  toml_test
end

hash = obj_to_toml_test(TOML::Parser.new(ARGF.read).parsed)

print JSON.dump(hash)
