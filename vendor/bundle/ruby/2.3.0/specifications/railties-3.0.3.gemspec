# -*- encoding: utf-8 -*-
# stub: railties 3.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "railties".freeze
  s.version = "3.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2010-11-16"
  s.description = "Rails internals: application bootup, plugins, generators, and rake tasks.".freeze
  s.email = "david@loudthinking.com".freeze
  s.homepage = "http://www.rubyonrails.org".freeze
  s.rdoc_options = ["--exclude".freeze, ".".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7".freeze)
  s.rubyforge_project = "rails".freeze
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "Tools for creating, working with, and running Rails applications.".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>.freeze, [">= 0.8.7"])
      s.add_runtime_dependency(%q<thor>.freeze, ["~> 0.14.4"])
      s.add_runtime_dependency(%q<activesupport>.freeze, ["= 3.0.3"])
      s.add_runtime_dependency(%q<actionpack>.freeze, ["= 3.0.3"])
    else
      s.add_dependency(%q<rake>.freeze, [">= 0.8.7"])
      s.add_dependency(%q<thor>.freeze, ["~> 0.14.4"])
      s.add_dependency(%q<activesupport>.freeze, ["= 3.0.3"])
      s.add_dependency(%q<actionpack>.freeze, ["= 3.0.3"])
    end
  else
    s.add_dependency(%q<rake>.freeze, [">= 0.8.7"])
    s.add_dependency(%q<thor>.freeze, ["~> 0.14.4"])
    s.add_dependency(%q<activesupport>.freeze, ["= 3.0.3"])
    s.add_dependency(%q<actionpack>.freeze, ["= 3.0.3"])
  end
end
