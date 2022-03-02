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
  def to_toml(path = '')
    return '' if empty?

    tables = {}
    values = {}
    keys.sort.each do |key|
      val = self[key]
      next if val.nil?

      if val.toml_table? || val.toml_table_array?
        tables[key] = val
      else
        values[key] = val
      end
    end

    pairs = values.map do |key, val|
      return nil unless key && val

      "#{key} = #{val.to_toml(key)}"
    end

    toml = pairs.reject.to_a.join("\n")

    tables.each do |key, val|
      key = "#{path}.#{key}" unless path.empty?
      toml_val = val.to_toml(key)
      next if toml_val.empty?
      if val.toml_table?
        non_table_vals = val.values.reject do |v|
          v.toml_table? || v.toml_table_array?
        end

        # Only add the table key if there are non table values.
        toml << "\n[#{key}]\n" if non_table_vals.length > 0
      end
      toml << toml_val
    end

    toml
  end
end

class Array
  def to_toml(path = '')
    raise 'All array values must be the same type' unless map(&:class).uniq.length == 1

    if first.toml_table?
      values = map do |val|
        "[[#{path}]]\n#{val.to_toml(path)}"
      end

      values.prepend ''

      values.join("\n")
    else
      "[#{map { |v| v.to_toml(path) }.join(',')}]"
    end
  end
end

class TrueClass
  def to_toml(*)
    'true'
  end
end

class FalseClass
  def to_toml(*)
    'false'
  end
end

class String
  def to_toml(*)
    inspect
  end
end

class Numeric
  def to_toml(*)
    to_s
  end

  def empty?
    false
  end
end

class DateTime
  def to_toml(*)
    rfc3339
  end
end

class NilClass
  def to_toml(*)
    ''
  end

  def empty?
    true
  end
end