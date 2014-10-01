
require 'rubygems'
require 'bundler/setup'

require 'toml'
require 'minitest/autorun'

class TestGenerator < MiniTest::Test
  def setup
    @doc = {
      "integer" => 1,
      "float" => 3.14159,
      "true" => true,
      "false" => false,
      "string" => "hi",
      "array" => [[1], [2], [3]],
      "table_array" => [
        {
          "name" => "first"
        },
        {
          "name" => "second",
          "sub_table_array" => [
            {
              "sub_name" => "sub first",
            },
            {
              "sub_name" => "sub second"
            }
          ]
        }
      ],
      "key" => {
        "group" => {
          "value" => "lol"
        },
        "nil_table" => {}
      },
      "date" => DateTime.now,
      "nil" => nil
    }
    
  end
  
  def test_generator
    doc = @doc.clone
    body = TOML::Generator.new(doc).body

    doc_parsed = TOML::Parser.new(body).parsed
    
    # removing the nil value
    remove_nil = doc.delete "nil"
    remove_nil_table = doc["key"].delete "nil_table"
    
    # Extracting dates since Ruby's DateTime equality testing sucks.
    original_date = doc.delete "date"
    parsed_date = doc_parsed.delete "date"
    assert_equal original_date.to_time.to_s, parsed_date.to_time.to_s

    refute doc_parsed.length > doc.length, "Parsed doc has more items than we started with."
    doc.each do |key, val|
      assert_equal val, doc_parsed[key]
    end
  end
end
