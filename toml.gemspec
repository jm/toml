require './lib/toml/version'

Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name              = 'toml'
  s.version           = TOML::VERSION

  ## Make sure your summary is short. The description may be as long
  ## as you like.
  s.summary     = "Parse your TOML."
  s.description = "Parse your TOML, seriously."

  ## List the primary authors. If there are a bunch of authors, it's probably
  ## better to set the email to an email list or something. If you don't have
  ## a custom homepage, consider using your GitHub URL or the like.
  s.authors  = ["Jeremy McAnally", "Dirk Gadsden"]
  s.email    = 'jeremy@github.com'
  s.homepage = 'http://github.com/jm/toml'
  s.license  = 'MIT'

  ## Specify any RDoc options here. You'll want to add your README and
  ## LICENSE files to the extra_rdoc_files list.
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE CHANGELOG.md]

  s.add_dependency "parslet", "~> 1.8.0"

  s.add_development_dependency "rake"

  all_files       = `git ls-files -z`.split("\x0")
  s.files         = all_files.grep(%r{^(bin|lib)/})
  s.executables   = all_files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
