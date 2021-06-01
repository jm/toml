require "bundler/setup"
require "toml"
require "minitest/autorun"

class TestFailure < MiniTest::Test
  def test_failure
    result = nil
    out, _err = capture_io do
      result = TOML::Parser.new("abc*123(")
    end

    assert_match(/line 1.*char 1/, out)
    assert_equal({}, result.parsed)
  end
end
