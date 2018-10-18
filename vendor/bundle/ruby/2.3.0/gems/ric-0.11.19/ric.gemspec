# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ric"
  s.version = "0.11.19"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Riccardo Carlesso"]
  s.date = "2011-12-11"
  s.description = "My first gem with various utilities (colors and tests now). \n  My name is Riccardo, hence 'ric' (ok I admit it, this was just ot prove Im able to build a sentence\n   with hence!)"
  s.email = "['p','ll','diusbonton].join('a') @ gmail.com"
  s.executables = ["itunes.rb", "ric", "riclib-test", "septober", "xcopy"]
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README.md", "TODO", "bin/itunes.rb", "bin/ric", "bin/riclib-test", "bin/septober", "bin/xcopy", "lib/rails/acts_as_carlesso.rb", "lib/rails/helpers/rails_helper.rb", "lib/ric.rb", "lib/ric/colors.rb", "lib/ric/conf.rb", "lib/ric/debug.rb", "lib/ric/files.rb", "lib/ric/html.rb", "lib/ric/zibaldone.rb", "lib/ruby_classes/arrays.rb", "lib/ruby_classes/strings.rb", "lib/tmp/uniquify.rb"]
  s.files = ["CHANGELOG", "HISTORY.yml", "LICENSE", "Manifest", "README.md", "Rakefile", "TODO", "VERSION", "bin/itunes.rb", "bin/ric", "bin/riclib-test", "bin/septober", "bin/xcopy", "init.rb", "lib/rails/acts_as_carlesso.rb", "lib/rails/helpers/rails_helper.rb", "lib/ric.rb", "lib/ric/colors.rb", "lib/ric/conf.rb", "lib/ric/debug.rb", "lib/ric/files.rb", "lib/ric/html.rb", "lib/ric/zibaldone.rb", "lib/ruby_classes/arrays.rb", "lib/ruby_classes/strings.rb", "lib/tmp/uniquify.rb", "rails/init.rb", "sbin/reboot.rb", "sbin/ric_reboot.rb", "test/sample_conf.yml", "test/strings_helper.rb", "test/test_helper.rb", "var/www/index.html", "ric.gemspec"]
  s.homepage = "http://github.com/palladius/ric"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Ric", "--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "ric"
  s.rubygems_version = "1.8.11"
  s.summary = "My first gem with various utilities (colors and tests now).  My name is Riccardo, hence 'ric' (ok I admit it, this was just ot prove Im able to build a sentence with hence!)"
  s.test_files = ["test/test_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activeresource>, [">= 0"])
      s.add_development_dependency(%q<activeresource>, [">= 0"])
      s.add_development_dependency(%q<echoe>, [">= 0"])
    else
      s.add_dependency(%q<activeresource>, [">= 0"])
      s.add_dependency(%q<activeresource>, [">= 0"])
      s.add_dependency(%q<echoe>, [">= 0"])
    end
  else
    s.add_dependency(%q<activeresource>, [">= 0"])
    s.add_dependency(%q<activeresource>, [">= 0"])
    s.add_dependency(%q<echoe>, [">= 0"])
  end
end
