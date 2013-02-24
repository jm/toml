module TOML
  class ParsletParser < ::Parslet::Parser
    
    rule(:value) {
      array.as(:array) |
      string |
      datetime.as(:datetime) |
      float.as(:float) |
      integer.as(:integer) |
      boolean
    }
    rule(:array) {
      str("[") >> (
        allspace >> value >>
        (allspace >> str(",") >> allspace >> value).repeat(0) >>
        allspace
      ).maybe >> str("]") 
    }
    
    rule(:keyvalue) { space >> key.as(:key) >> space >> str("=") >> space >> value >> space >> comment.maybe >> str("\n") >> allspace }
    rule(:keygroup) { space >> str("[") >> keygroupname.as(:keygroup) >> str("]") >> space >> comment.maybe >> str("\n") >> allspace }
    rule(:commentline) { comment >> str("\n") >> allspace }
    
    rule(:document) { (keygroup | keyvalue | commentline).repeat(0) }
    root :document
    
    rule(:comment) { str("#") >> match("[^\n]").repeat(0) }
    rule(:space) { match("[ \t]").repeat(0) }
    rule(:allspace) { match("[ \t\r\n]").repeat(0) }
    
    rule(:key) { match("[^. \t\\]]").repeat(1) }
    rule(:keygroupname) { key.as(:key) >> (str(".") >> key.as(:key)).repeat(0) }
    
    rule(:string) {
      str('"') >> (
      match("[^\"\\\\]") |
      (str("\\") >> match("[0tnr\"\\\\]"))
      ).repeat(0).as(:string) >> str('"')
    }
    
    rule(:sign) { str("-") }
    rule(:integer) {
      str("0") | (sign.maybe >> match("[1-9]") >> match("[0-9]").repeat(0))
    }
    rule(:float) {
      sign.maybe >> match("[0-9]").repeat(1) >> str(".") >> match("[0-9]").repeat(1)
    }
    rule(:boolean) { str("true").as(:true) | str("false").as(:false) }
    
    rule(:date) {
      match("[0-9]").repeat(4,4) >> str("-") >>
      match("[0-9]").repeat(2,2) >> str("-") >>
      match("[0-9]").repeat(2,2)
    }
    rule(:time) {
      match("[0-9]").repeat(2,2) >> str(":") >>
      match("[0-9]").repeat(2,2) >> str(":") >>
      match("[0-9]").repeat(2,2)
    }
    rule(:datetime) { date >> str("T") >> time >> str("Z") }
    
  end
  
  class Key
    attr_reader :key, :value
    def initialize(key, value)
      @key = key
      @value = value
    end
  end
  class KeyGroup
    attr_reader :keys
    def initialize(keys)
      @keys = keys
    end
  end
  
  class ParsletTransformer < ::Parslet::Transform
    
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
    # Clean up simples (inside arrays)
    rule(:integer => simple(:i)) { i.to_i }
    rule(:float => simple(:f)) { f.to_f }
    rule(:string => simple(:s)) {
      ParsletTransformer.parse_string(s.to_s)
    }
    rule(:datetime => simple(:d)) { DateTime.iso8601(d) }
    rule(:true => simple(:b)) { true }
    rule(:false => simple(:b)) { false }
    
    # TODO: Refactor to remove redundancy
    rule(:key => simple(:k), :array => subtree(:ar)) { Key.new(k.to_s, ar) }
    rule(:key => simple(:k), :integer => simple(:i)) { Key.new(k.to_s, i.to_i) }
    rule(:key => simple(:k), :float => simple(:f)) { Key.new(k.to_s, f.to_f) }
    rule(:key => simple(:k), :string => simple(:s)) {
      Key.new(k.to_s, ParsletTransformer.parse_string(s.to_s))
    }
    rule(:key => simple(:k), :datetime => simple(:d)) {
      Key.new(k.to_s, DateTime.iso8601(d))
    }
    rule(:key => simple(:k), :true => simple(:b)) { Key.new(k.to_s, true) }
    rule(:key => simple(:k), :false => simple(:b)) { Key.new(k.to_s, false) }
    
    # Make keys just be strings
    rule(:key => simple(:k)) { k }
    # Then objectify the keygroups
    rule(:keygroup => simple(:kg)) {
      KeyGroup.new([kg.to_s])
    }
    # Captures array-like key-groups
    rule(:keygroup => subtree(:kg)) {
      KeyGroup.new(kg.map &:to_s)
    }
    
  end
  
  class Parser2
    attr_reader :parsed
    def initialize(markup)
      tree = ParsletParser.new.parse(markup)
      parts = ParsletTransformer.new.apply(tree)
      
      @parsed = {}
      @current = @parsed
      
      parts.each do |part|
        if part.is_a? Key
          @current[part.key] = part.value
        elsif part.is_a? KeyGroup
          resolve_key_group(part)
        else
          raise "Unrecognized part: #{part.inspect}"
        end
      end
      
    end
    
    def resolve_key_group(kg)
      @current = @parsed
      path = kg.keys.dup
      while k = path.shift
        if @current.has_key? k
          # pass
        else
          @current[k] = {}
        end
        @current = @current[k]
      end
    end
    
  end
  
end
