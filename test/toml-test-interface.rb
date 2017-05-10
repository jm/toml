#!/usr/bin/env ruby
require File.expand_path('../../lib/toml.rb', __FILE__)
require 'json'
toml = $stdin.read
puts JSON.dump(TOML.load(toml))
