
require 'rubygems'
require 'bundler/setup'

require 'toml'
require 'minitest/autorun'

class TestGenerator < MiniTest::Unit::TestCase
  def setup
    @doc = {
      "integer" => 1,
      "float" => 3.14159,
      "true" => true,
      "false" => false,
      "string" => "hi",
      "array" => [[1], 2, [3]],
      "key" => {
        "group" => {
          "value" => "lol"
        }
      }
    }
    
  end
  
  def test_generator
    body = TOML::Generator.new(@doc).body

    doc_parsed = TOML::Parser.new(body).parsed
    
    assert_equal @doc, doc_parsed
  end
end
