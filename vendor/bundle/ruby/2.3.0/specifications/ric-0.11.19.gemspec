# -*- encoding: utf-8 -*-
# stub: ric 0.11.19 ruby lib

Gem::Specification.new do |s|
  s.name = "ric".freeze
  s.version = "0.11.19"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Riccardo Carlesso".freeze]
  s.date = "2011-12-11"
  s.description = "My first gem with various utilities (colors and tests now). \n  My name is Riccardo, hence 'ric' (ok I admit it, this was just ot prove Im able to build a sentence\n   with hence!)".freeze
  s.email = "['p','ll','diusbonton].join('a') @ gmail.com".freeze
  s.executables = ["itunes.rb".freeze, "ric".freeze, "riclib-test".freeze, "septober".freeze, "xcopy".freeze]
  s.extra_rdoc_files = ["CHANGELOG".freeze, "LICENSE".freeze, "README.md".freeze, "TODO".freeze, "bin/itunes.rb".freeze, "bin/ric".freeze, "bin/riclib-test".freeze, "bin/septober".freeze, "bin/xcopy".freeze, "lib/rails/acts_as_carlesso.rb".freeze, "lib/rails/helpers/rails_helper.rb".freeze, "lib/ric.rb".freeze, "lib/ric/colors.rb".freeze, "lib/ric/conf.rb".freeze, "lib/ric/debug.rb".freeze, "lib/ric/files.rb".freeze, "lib/ric/html.rb".freeze, "lib/ric/zibaldone.rb".freeze, "lib/ruby_classes/arrays.rb".freeze, "lib/ruby_classes/strings.rb".freeze, "lib/tmp/uniquify.rb".freeze]
  s.files = ["CHANGELOG".freeze, "LICENSE".freeze, "README.md".freeze, "TODO".freeze, "bin/itunes.rb".freeze, "bin/ric".freeze, "bin/riclib-test".freeze, "bin/septober".freeze, "bin/xcopy".freeze, "lib/rails/acts_as_carlesso.rb".freeze, "lib/rails/helpers/rails_helper.rb".freeze, "lib/ric.rb".freeze, "lib/ric/colors.rb".freeze, "lib/ric/conf.rb".freeze, "lib/ric/debug.rb".freeze, "lib/ric/files.rb".freeze, "lib/ric/html.rb".freeze, "lib/ric/zibaldone.rb".freeze, "lib/ruby_classes/arrays.rb".freeze, "lib/ruby_classes/strings.rb".freeze, "lib/tmp/uniquify.rb".freeze]
  s.homepage = "http://github.com/palladius/ric".freeze
  s.rdoc_options = ["--line-numbers".freeze, "--inline-source".freeze, "--title".freeze, "Ric".freeze, "--main".freeze, "README.md".freeze]
  s.rubyforge_project = "ric".freeze
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "My first gem with various utilities (colors and tests now).  My name is Riccardo, hence 'ric' (ok I admit it, this was just ot prove Im able to build a sentence with hence!)".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activeresource>.freeze, [">= 0"])
      s.add_development_dependency(%q<activeresource>.freeze, [">= 0"])
      s.add_development_dependency(%q<echoe>.freeze, [">= 0"])
    else
      s.add_dependency(%q<activeresource>.freeze, [">= 0"])
      s.add_dependency(%q<activeresource>.freeze, [">= 0"])
      s.add_dependency(%q<echoe>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<activeresource>.freeze, [">= 0"])
    s.add_dependency(%q<activeresource>.freeze, [">= 0"])
    s.add_dependency(%q<echoe>.freeze, [">= 0"])
  end
end
