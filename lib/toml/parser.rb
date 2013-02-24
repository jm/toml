module TOML
  class Parser
    attr_reader :parsed

    def initialize(markup)
      lines = markup.split("\n").reject {|l| l.start_with?("#") }

      @parsed = {}
      @current_key_group = ""

      lines.each do |line|
        if line.gsub(/\s/, '').empty?
          close_key_group
        elsif line =~ /^\s?\[(.*)\]/
          new_key_group($1)
        elsif line =~ /\s?(.*)=(.*)/
          add_key($1, $2)
        else
          raise "lmao i have no clue what you're doing: #{line}"
        end
      end
    end

    def new_key_group(key_name)
      @current_key_group = key_name
    end

    def add_key(key, value)
      @parsed[@current_key_group] ||= {}
      @parsed[@current_key_group][key.strip] = coerce(strip_comments(value))
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
        return $1
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
      @current_key_group = ""
    end
  end
end