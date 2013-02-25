module TOML
  class KeyGroup
    attr_reader :keys
    
    def initialize(keys)
      @keys = keys
    end
  end
end