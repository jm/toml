$:.unshift(File.dirname(__FILE__))

require 'time'
# lmao unescaping
require 'syck/encoding'
require 'yaml'

require 'parslet'

require 'toml/key'
require 'toml/key_group'
require 'toml/parslet'
require 'toml/transformer'
require 'toml/parser'

module TOML
  VERSION = '0.0.1'
end