# -*- encoding: utf-8 -*-
# stub: mocha 0.10.5 ruby lib

Gem::Specification.new do |s|
  s.name = "mocha".freeze
  s.version = "0.10.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["James Mead".freeze]
  s.date = "2012-02-29"
  s.description = "Mocking and stubbing library with JMock/SchMock syntax, which allows mocking and stubbing of methods on real (non-mock) classes.".freeze
  s.email = "mocha-developer@googlegroups.com".freeze
  s.extra_rdoc_files = ["README.rdoc".freeze, "COPYING.rdoc".freeze]
  s.files = ["COPYING.rdoc".freeze, "README.rdoc".freeze]
  s.homepage = "http://mocha.rubyforge.org".freeze
  s.rdoc_options = ["--title".freeze, "Mocha".freeze, "--main".freeze, "README.rdoc".freeze, "--line-numbers".freeze]
  s.rubyforge_project = "mocha".freeze
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "Mocking and stubbing library".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<metaclass>.freeze, ["~> 0.0.1"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<introspection>.freeze, ["~> 0.0.1"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 3.1"])
      s.add_development_dependency(%q<coderay>.freeze, ["~> 0.1"])
    else
      s.add_dependency(%q<metaclass>.freeze, ["~> 0.0.1"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<introspection>.freeze, ["~> 0.0.1"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 3.1"])
      s.add_dependency(%q<coderay>.freeze, ["~> 0.1"])
    end
  else
    s.add_dependency(%q<metaclass>.freeze, ["~> 0.0.1"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<introspection>.freeze, ["~> 0.0.1"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 3.1"])
    s.add_dependency(%q<coderay>.freeze, ["~> 0.1"])
  end
end
