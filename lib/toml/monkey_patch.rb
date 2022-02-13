# Adds to_toml methods to base Ruby classes used by the generator.
class Object
  def toml_table?
    is_a?(Hash)
  end

  def toml_table_array?
    is_a?(Array) && first.toml_table?
  end
end

class Hash
  def to_toml(path = "", preserve = false)
    return "" if empty?

    tables = {}
    values = {}
    if preserve
      keys.each do |key|
        val = self[key]
        if val.is_a?(NilClass)
          next
        elsif val.toml_table? || val.toml_table_array?
          tables[key] = val
        else
          values[key] = val
        end
      end
    else
      keys.sort.each do |key|
        val = self[key]
        if val.is_a?(NilClass)
          next
        elsif val.toml_table? || val.toml_table_array?
          tables[key] = val
        else
          values[key] = val
        end
      end
    end

    toml = ""
    values.each do |key, val|
      toml << "#{key} = #{val.to_toml(key)}\n"
    end

    tables.each do |key, val|
      key = "#{path}.#{key}" unless path.empty?
      toml_val = val.to_toml(key)
      unless toml_val.empty?
        if val.toml_table?
          non_table_vals = val.values.reject do |v|
            v.toml_table? || v.toml_table_array?
          end

          # Only add the table key if there are non table values.
          if non_table_vals.length > 0
            toml << "\n[#{key}]\n"
          end
        end
        toml << toml_val
      end
    end

    toml
  end
end

class Array
  def to_toml(path = "")
    unless map(&:class).uniq.length == 1
      raise "All array values must be the same type"
    end

    if first.toml_table?
      toml = ""
      each do |val|
        toml << "\n[[#{path}]]\n"
        toml << val.to_toml(path)
      end
      toml
    else
      "[" + map { |v| v.to_toml(path) }.join(",") + "]"
    end
  end
end

class TrueClass
  def to_toml(path = "") = "true"
end

class FalseClass
  def to_toml(path = "") = "false"
end

class String
  def to_toml(path = "") = inspect
end

class Numeric
  def to_toml(path = "") = to_s
end

class DateTime
  def to_toml(path = "")
    rfc3339
  end
end
