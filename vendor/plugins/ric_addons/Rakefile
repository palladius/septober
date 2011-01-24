require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

# Copied from here: 
# 1. http://www.themodestrubyist.com/2010/03/05/rails-3-plugins---part-2---writing-an-engine/
# 2. http://www.railsfire.com/article/building-dry-gems-thor-and-jeweler
begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "ric_addons"
    gem.summary = "RicAddons experimental Engine for Rails 3 (summary)"
    gem.files = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*", 
      "README", "VERSION"
    ]
    gem.email = "riccardo.carlesso@gmail.com"
    gem.homepage = "http://github.com/palaldius/ric_addons"
    gem.description = "RicAddons experimental Engine for Rails 3 (description)"
    gem.authors = ["Riccardo Carlesso"]
    # other fields that would normally go in your gemspec
    # like authors, email and has_rdoc can also be included here
  end
rescue
  puts "Jeweler or one of its dependencies is not installed."
end

### # Tests...
### desc 'Default: run unit tests.'
### task :default => :test
### 
### desc 'Test the ric_plugin plugin.'
### Rake::TestTask.new(:test) do |t|
###   t.libs << 'lib'
###   t.libs << 'test'
###   t.pattern = 'test/**/*_test.rb'
###   t.verbose = true
### end
### 
### desc 'Generate documentation for the ric_plugin plugin.'
### Rake::RDocTask.new(:rdoc) do |rdoc|
###   rdoc.rdoc_dir = 'rdoc'
###   rdoc.title    = 'RicPlugin'
###   rdoc.options << '--line-numbers' << '--inline-source'
###   rdoc.rdoc_files.include('README')
###   rdoc.rdoc_files.include('lib/**/*.rb')
### end