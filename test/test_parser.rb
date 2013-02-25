
require 'rubygems'
require 'bundler/setup'

require 'toml'
require 'minitest/autorun'

class TestParser < MiniTest::Unit::TestCase
  def setup
    filepath = File.join(File.dirname(__FILE__), 'spec.toml')
    @doc = TOML::Parser.new(File.read(filepath)).parsed
  end
  
  def test_string
    assert_equal @doc["string"], "string\n\t\"string"
  end

  def test_integer
    assert_equal @doc["integer"], 42
  end

  def test_float
    assert_equal @doc["pi"], 3.14159
  end

  def test_datetime
    assert_equal @doc["datetime"], DateTime.iso8601("1979-05-27T07:32:00Z")
  end

  def test_booleans
    assert_equal @doc["true"], true
    assert_equal @doc["false"], false
  end

  def test_simple_array
    assert_equal @doc["arrays"]["simple"], [1, 2, 3]
  end

  def test_nested_array
    assert_equal @doc["arrays"]["nested"], [[[1], 2], 3]
  end

  def test_simple_keygroup
    assert_equal @doc["e"]["f"], "test"
  end

  def test_nested_keygroup
    assert_equal @doc["a"]["b"]["c"]["d"], "test"
  end

  def test_multiline_arrays
    assert_equal ["lines", "are", "super", "cool", "lol", "amirite"], @doc["arrays"]["multi"]
  end
end
