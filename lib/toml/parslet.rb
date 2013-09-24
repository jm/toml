module TOML
  class Parslet < ::Parslet::Parser
    rule(:document) {
      all_space >>
      (key_group | key_value | comment_line).repeat >>
      all_space
    }
    root :document

    rule(:value) {
      array |
      string |
      datetime.as(:datetime) |
      float.as(:float) |
      integer.as(:integer) |
      boolean
    }
    
    # Finding comments in multiline arrays requires accepting a bunch of
    # possible newlines and stuff before the comment
    rule(:array_comments) { (all_space >> comment_line).repeat }
    
    rule(:array) {
      str("[") >> ( array_comments >> # Match any comments on first line
        all_space >> value >> array_comments >>
        (
          # Separator followed by any comments
          all_space >> str(",") >> array_comments >>
          # Value followed by any comments
          all_space >> value >> array_comments
        ).repeat >>
        all_space >> array_comments # Grab any remaining comments just in case
      ).maybe.as(:array) >> str("]") 
    }
    
    rule(:key_value) { 
      space.maybe >> key.as(:key) >>
      space.maybe >> str("=") >>
      space.maybe >> value.as(:value) >>
      space.maybe >> comment.maybe >> str("\n") >> all_space
    }
    rule(:key_group) {
      space.maybe >> str("[") >>
        key_group_name.as(:key_group) >>
      str("]") >>
      space.maybe >> comment.maybe >> str("\n") >> all_space
    }
    
    rule(:key) { match["^. \t\\]"].repeat(1) }
    rule(:key_group_name) { key.as(:key) >> (str(".") >> key.as(:key)).repeat }

    rule(:comment_line) { comment >> str("\n") >> all_space }
    rule(:comment) { str("#") >> match["^\n"].repeat }

    rule(:space) { match[" \t"].repeat }
    rule(:all_space) { (match[" \t\r\n"].repeat).maybe }
        
    rule(:string) {
      str('"') >> (
      match["^\"\\\\"] |
      (str("\\") >> match["0tnr\"\\\\"])
      ).repeat.as(:string) >> str('"')
    }
    
    rule(:sign) { str("-") }
    rule(:sign?) { sign.maybe }
    
    rule(:integer) {
      str("0") | (sign? >> match["1-9"] >> match["0-9"].repeat)
    }
    rule(:float) {
      sign? >> match["0-9"].repeat(1) >> str(".") >> match["0-9"].repeat(1)
    }

    rule(:boolean) { str("true").as(:true) | str("false").as(:false) }
    
    rule(:date) {
      match["0-9"].repeat(4,4) >> str("-") >>
      match["0-9"].repeat(2,2) >> str("-") >>
      match["0-9"].repeat(2,2)
    }

    rule(:time) {
      match["0-9"].repeat(2,2) >> str(":") >>
      match["0-9"].repeat(2,2) >> str(":") >>
      match["0-9"].repeat(2,2)
    }

    rule(:datetime) { date >> str("T") >> time >> str("Z") }
  end
end
