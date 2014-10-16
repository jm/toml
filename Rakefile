require 'rubygems'
require 'bundler/gem_tasks'
require 'rake'
require 'date'
require './lib/toml/version'

#############################################################################
#
# Helper functions
#
#############################################################################

def name
  @name ||= Dir['*.gemspec'].first.split('.').first
end

def version
  TOML::VERSION
end

def date
  Date.today.to_s
end

#############################################################################
#
# Standard tasks
#
#############################################################################

task :default => :test

# require 'rake/testtask'
# Rake::TestTask.new(:test) do |test|
#   test.libs << 'lib' << 'test'
#   test.pattern = 'test/**/test_*.rb'
#   test.verbose = true
# end
task :test do
  Dir['./test/**/test_*.rb'].each {|f| require f }
end

desc "Generate RCov test coverage and open in your browser"
task :coverage do
  if RUBY_VERSION =~ /^1\./
    require 'rubygems'
    require 'bundler'
    Bundler.setup(:test)
    require 'simplecov'
    require 'simplecov-gem-adapter'

    sh "rm -fr coverage"
    SimpleCov.command_name 'Unit Tests'
    SimpleCov.start 'gem'
    Rake::Task[:test].invoke
    SimpleCov.at_exit do
      SimpleCov.result.format!
      sh "open coverage/index.html"
    end
  else
    require 'rcov'
    sh "rm -fr coverage"
    sh "rcov test/test_*.rb"
    sh "open coverage/index.html"
  end
end

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "#{name} #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/#{name}.rb"
end
