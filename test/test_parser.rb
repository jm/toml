
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
    assert_equal "string\n\t\"string", @doc["string"]
  end

  def test_integer
    assert_equal 42, @doc["integer"]
  end

  def test_float
    assert_equal 3.14159, @doc["pi"]
  end

  def test_datetime
    assert_equal DateTime.iso8601("1979-05-27T07:32:00Z"), @doc["datetime"]
  end

  def test_booleans
    assert_equal true, @doc["true"]
    assert_equal false, @doc["false"]
  end

  def test_simple_array
    assert_equal [1, 2, 3], @doc["arrays"]["simple"]
  end

  def test_nested_array
    assert_equal [[[1], 2], 3], @doc["arrays"]["nested"]
  end

  def test_simple_keygroup
    assert_equal "test", @doc["e"]["f"]
  end

  def test_nested_keygroup
    assert_equal "test", @doc["a"]["b"]["c"]["d"]
  end

  def test_multiline_arrays
    assert_equal ["lines", "are", "super", "cool", "lol", "amirite"], @doc["arrays"]["multi"]
  end
end
