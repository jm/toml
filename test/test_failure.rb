require "bundler/setup"
require "toml"
require "minitest/autorun"

class TestFailure < MiniTest::Test
  def test_failure
    assert_raises Parslet::ParseFailed do
      result = TOML::Parser.new("abc*123(")
    end
  end
end
