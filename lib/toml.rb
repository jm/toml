$:.unshift(File.dirname(__FILE__))

require 'time'
# lmao unescaping
require 'syck/encoding'
require 'yaml'

require 'toml/parser'

require 'parslet'
require 'toml/parser2'

module TOML
  VERSION = '0.0.1'
end