require 'rubygems'
require 'rake'
require 'echoe'

version = File.read( 'VERSION' ) rescue "0.0.42_bugged"

Echoe.new('ric', version ) do |p|
  p.description    = "My first gem with various utilities (colors and tests now). 
  My name is Riccardo, hence 'ric' (ok I admit it, this was just ot prove Im able to build a sentence
   with hence!)"
  p.url            = "http://github.com/palladius/ric"
  p.author         = "Riccardo Carlesso"
  p.email          = "['p','ll','diusbonton].join('a') @ gmail.com"
  p.ignore_pattern = [
    "tmp/*", 
    "docs/*", 
    "script/*", 
    "tmp/*", "tmp/*/*", "tmp/*/*/*",
    "images/*/*/*", "images/*/*", 'images', 
    "private/*",
    ".noheroku",
    "HISTORY"
  ]
  p.development_dependencies = [ 'activeresource','echoe' ]
  p.runtime_dependencies = [ 'activeresource' ]
end

#### RAKE TEST
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the ric gem'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the ric gem'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Ric GEM Hehehe'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('HISTORY.yml')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
