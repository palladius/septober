# -*- encoding: utf-8 -*-
# stub: actionpack 3.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "actionpack".freeze
  s.version = "3.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2010-11-16"
  s.description = "Web apps on Rails. Simple, battle-tested conventions for building and testing MVC web applications. Works with any Rack-compatible server.".freeze
  s.email = "david@loudthinking.com".freeze
  s.homepage = "http://www.rubyonrails.org".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7".freeze)
  s.requirements = ["none".freeze]
  s.rubyforge_project = "actionpack".freeze
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "Web-flow and rendering framework putting the VC in MVC (part of Rails).".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, ["= 3.0.3"])
      s.add_runtime_dependency(%q<activemodel>.freeze, ["= 3.0.3"])
      s.add_runtime_dependency(%q<builder>.freeze, ["~> 2.1.2"])
      s.add_runtime_dependency(%q<i18n>.freeze, ["~> 0.4"])
      s.add_runtime_dependency(%q<rack>.freeze, ["~> 1.2.1"])
      s.add_runtime_dependency(%q<rack-test>.freeze, ["~> 0.5.6"])
      s.add_runtime_dependency(%q<rack-mount>.freeze, ["~> 0.6.13"])
      s.add_runtime_dependency(%q<tzinfo>.freeze, ["~> 0.3.23"])
      s.add_runtime_dependency(%q<erubis>.freeze, ["~> 2.6.6"])
    else
      s.add_dependency(%q<activesupport>.freeze, ["= 3.0.3"])
      s.add_dependency(%q<activemodel>.freeze, ["= 3.0.3"])
      s.add_dependency(%q<builder>.freeze, ["~> 2.1.2"])
      s.add_dependency(%q<i18n>.freeze, ["~> 0.4"])
      s.add_dependency(%q<rack>.freeze, ["~> 1.2.1"])
      s.add_dependency(%q<rack-test>.freeze, ["~> 0.5.6"])
      s.add_dependency(%q<rack-mount>.freeze, ["~> 0.6.13"])
      s.add_dependency(%q<tzinfo>.freeze, ["~> 0.3.23"])
      s.add_dependency(%q<erubis>.freeze, ["~> 2.6.6"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, ["= 3.0.3"])
    s.add_dependency(%q<activemodel>.freeze, ["= 3.0.3"])
    s.add_dependency(%q<builder>.freeze, ["~> 2.1.2"])
    s.add_dependency(%q<i18n>.freeze, ["~> 0.4"])
    s.add_dependency(%q<rack>.freeze, ["~> 1.2.1"])
    s.add_dependency(%q<rack-test>.freeze, ["~> 0.5.6"])
    s.add_dependency(%q<rack-mount>.freeze, ["~> 0.6.13"])
    s.add_dependency(%q<tzinfo>.freeze, ["~> 0.3.23"])
    s.add_dependency(%q<erubis>.freeze, ["~> 2.6.6"])
  end
end
