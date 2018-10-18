# -*- encoding: utf-8 -*-
# stub: thor 0.14.6 ruby lib

Gem::Specification.new do |s|
  s.name = "thor".freeze
  s.version = "0.14.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Yehuda Katz".freeze, "Jos\u{c3}\u{a9} Valim".freeze]
  s.date = "2010-11-20"
  s.description = "A scripting framework that replaces rake, sake and rubigen".freeze
  s.email = ["ruby-thor@googlegroups.com".freeze]
  s.executables = ["rake2thor".freeze, "thor".freeze]
  s.extra_rdoc_files = ["CHANGELOG.rdoc".freeze, "LICENSE".freeze, "README.md".freeze, "Thorfile".freeze]
  s.files = ["CHANGELOG.rdoc".freeze, "LICENSE".freeze, "README.md".freeze, "Thorfile".freeze, "bin/rake2thor".freeze, "bin/thor".freeze]
  s.homepage = "http://github.com/wycats/thor".freeze
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "A scripting framework that replaces rake, sake and rubigen".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<fakeweb>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 2.5"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0.8"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 2.1"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.3"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
      s.add_dependency(%q<fakeweb>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 2.5"])
      s.add_dependency(%q<rake>.freeze, [">= 0.8"])
      s.add_dependency(%q<rspec>.freeze, ["~> 2.1"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.3"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
    s.add_dependency(%q<fakeweb>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 2.5"])
    s.add_dependency(%q<rake>.freeze, [">= 0.8"])
    s.add_dependency(%q<rspec>.freeze, ["~> 2.1"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.3"])
  end
end
