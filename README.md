# TOML

A sane configuration format from @mojombo.  More information here: https://github.com/mojombo/toml

This is far superior to YAML and JSON because it doesn't suck.

## Usage

It's simple, really.

```ruby
content = <<-TOML

# Hello, this is an example.
[things]
other = "things"
what = 900000

TOML

parser = TOML::Parser.new(content).parsed
# => { "things" => { "other" => "things", "what" => 900000 } }
```

You can also use the same API as `YAML` if you'd like:

```ruby
TOML.load("thing = 9")
# => {"thing" => 9}

TOML.load_file("my_file.toml")
# => {"whatever" => "keys"}
```

## Contributors

Written by Jeremy McAnally (@jm) and Dirk Gadsden (@dirk) based on TOML from Tom Preston-Werner (@mojombo).