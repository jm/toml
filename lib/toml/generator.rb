
module TOML  
  class Generator
    attr_reader :body, :doc

    def initialize(doc)
      @body = ""
      @doc = doc
      
      visit(@doc)
      
      return @body
    end
    
    def visit(hash, path = "")
      hash_pairs = [] # Sub-hashes
      other_pairs = []
      
      hash.keys.sort.each do |key|
        val = hash[key]
        # TODO: Refactor for other hash-likes (OrderedHash)
        if val.is_a? Hash
          hash_pairs << [key, val]
        else
          other_pairs << [key, val]
        end
      end
      
      # Handle all the key-values
      if !path.empty? && !other_pairs.empty?
        @body += "[#{path}]\n"
      end
      other_pairs.each do |pair|
        key, val = pair
        @body += "#{key} = #{format(val)}\n"
      end
      @body += "\n" unless other_pairs.empty?
      
      # Then deal with sub-hashes
      hash_pairs.each do |pair|
        key, hash = pair
        visit(hash, (path.empty? ? key : [path, key].join(".")))
      end
    end#visit
    
    # Returns the value formatted for TOML.
    def format(val)
      # For most everything this should work just fine.
      val.inspect # TODO: Real escaping and such.
    end
    
  end#Generator
end#TOML
