module TOML
  class Parser
    attr_reader :parsed

    def initialize(markup)
      lines = markup.split("\n").reject {|l| l =~ /[\s]?#/ }

      @parsed = {}
      @current_key_group = ""
      @current_set = {}

      lines.each do |line|
        if line.gsub(/\s/, '').empty?
          close_key_group
        elsif line =~ /^\s*\[(.*)\]/
          new_key_group($1)
        elsif line =~ /\s?(.*)=(.*)/
          add_key($1, $2)
        else
          raise "lmao i have no clue what you're doing: #{line}"
        end
      end

      close_key_group unless @current_key_group.empty?
    end

    def new_key_group(key_name)
      @current_key_group = key_name
    end

    def add_key(key, value)
      @current_set[key.strip] = coerce(strip_comments(value))
    end

    def strip_comments(text)
      text.split("#").first
    end

    def coerce(value)
      value = value.strip

      # booleans
      if value == "true"
        return true
      elsif value == "false"
        return false
      end

      if value =~ /\[(.*)\]/
        # array
        array = $1.split(",").map {|s| s.strip.gsub(/\"(.*)\"/, '\1')}
        return array
      elsif value =~ /\"(.*)\"/
        # string
        return Syck.unescape($1)
      end

      # times
      begin
        time = Time.parse(value)
        return time
      rescue
      end

      # ints
      begin
        int = Integer(value)
        return int
      rescue
      end

      # floats
      begin
        float = Float(value)
        return float
      rescue
      end

      raise "lol no clue what [#{value}] is"
    end

    def close_key_group
      pieces = @current_key_group.split(".")
      top_level_key = pieces.shift

      value = if pieces.empty?
        @current_set
      else
        nest_pieces(pieces, @current_set)
      end

      deep_merge_hash(@parsed, {top_level_key => value})

      @current_set = {}
      @current_key_group = ""
    end

    def nest_pieces(pieces, final_value)
      return final_value if pieces.empty?
      {pieces.shift => nest_pieces(pieces, final_value)}
    end

    def deep_merge_hash(hash, other_hash)
      other_hash.each_pair do |k,v|
        tv = hash[k]
        if tv.is_a?(Hash) && v.is_a?(Hash)
          hash[k] = deep_merge_hash(tv, v)
        else
          hash[k] = v
        end
      end

      hash
    end
  end
end