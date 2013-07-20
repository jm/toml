module TOML  
  class Parser
    attr_reader :parsed

    def initialize(markup)
      # Make sure we have a newline on the end
      
      markup += "\n" unless markup.end_with?("\n") || markup.length == 0
      begin
        tree = Parslet.new.parse(markup)
      rescue Parslet::ParseFailed => failure
        puts failure.cause.ascii_tree
      end
      
      
      parts = Transformer.new.apply(tree) || []
      @parsed = {}
      @current = @parsed
      @current_path = ''
      
      parts.each do |part|
        if part.is_a? Key
          # Make sure the key isn't already set
          if !@current.is_a?(Hash) || @current.has_key?(part.key)
            err = "Cannot override key '#{part.key}'"
            unless @current_path.empty?
              err += " at path '#{@current_path}'"
            end
            raise err
          end
          # Set the key-value into the current hash
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
      @current_path = path.join('.')
      
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
