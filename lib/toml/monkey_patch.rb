# Adds to_toml methods to base Ruby classes used by the generator.
class TrueClass
  def to_toml; "true"; end
end
class FalseClass
  def to_toml; "false"; end
end
class String
  def to_toml; self.inspect; end
end
class Numeric
  def to_toml; self.to_s; end
end
class Array
  def to_toml
    # TODO: Add validations to make sure all values are the same type.
    "[" + self.map {|v| v.to_toml }.join(",") + "]"
  end
end
