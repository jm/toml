module TOML
  class Transformer < ::Parslet::Transform
    # Utility to properly handle escape sequences in parsed string.
    def self.parse_string(val)
      e = val.length
      s = 0
      o = []
      while s < e
        if val[s] == "\\"
          s += 1
          case val[s]
          when "t"
            o << "\t"
          when "n"
            o << "\n"
          when "\\"
            o << "\\"
          when '"'
            o << '"'
          when "r"
            o << "\r"
          when "0"
            o << "\0"
          else
            raise "Unexpected escape character: '\\#{val[s]}'"
          end
        else
          o << val[s]
        end
        s += 1
      end
      o.join
    end
    
    # Clean up arrays
    rule(:array => subtree(:ar)) { ar.is_a?(Array) ? ar : [ar] }

    # Clean up simple value hashes
    rule(:integer => simple(:i)) { i.to_i }
    rule(:float => simple(:f)) { f.to_f }
    rule(:string => simple(:s)) {
      Transformer.parse_string(s.to_s)
    }
    rule(:datetime => simple(:d)) { DateTime.iso8601(d) }
    rule(:true => simple(:b)) { true }
    rule(:false => simple(:b)) { false }
    
    rule(:key => simple(:k), :value => subtree(:v)) { Key.new(k.to_s, v) }
    
    # Make key hashes (inside key_groups) just be strings
    rule(:key => simple(:k)) { k }

    # Then objectify the key_groups
    rule(:key_group => simple(:kg)) {
      KeyGroup.new([kg.to_s])
    }

    # Captures array-like key-groups
    rule(:key_group => subtree(:kg)) {
      KeyGroup.new(kg.map &:to_s)
    }
  end
end