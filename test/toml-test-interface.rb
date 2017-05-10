#!/usr/bin/env ruby

def prelude
  [
    "=" * 60,
    Time.new.to_s,
    "=" * 60
  ].join("\n")
end

def log(txt)
  File.open("run_log.txt", "a") {|f| f.puts(prelude);f.write(txt) }
end

require "bundler"
Bundler.require

require "toml"
require "json"

raw = ARGF.read
log(raw)
begin
  decoded = TOML.load(raw)
rescue
  exit 1
end

def transform_toml(t)
  jsonified = t.reduce({}) do |j, (k, v)|
    j.merge k => transform_toml_value(v)
  end
end

def transform_toml_value(v)
  type, value = case v
  when String then ["string", v]
  when Fixnum, Bignum then ["integer", v.to_s]
  when Float then ["float", v.to_s]
  when DateTime then ["datetime", v.strftime("%Y-%m-%dT%H:%M:%SZ")]
  when TrueClass, FalseClass then ["bool", v.to_s]
  when Array then ["array", v.map { |e| transform_toml_value(e) }]
  when Hash
    return transform_toml(v)
  else raise "Unhandled type: #{v.class}"
  end
  { "type" => type, "value" => value }
end

puts transform_toml(decoded).to_json
