# -*- encoding: utf-8 -*-
# stub: rack-mount 0.6.13 ruby lib

Gem::Specification.new do |s|
  s.name = "rack-mount".freeze
  s.version = "0.6.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Joshua Peek".freeze]
  s.date = "2010-08-31"
  s.description = "Stackable dynamic tree based Rack router".freeze
  s.email = "josh@joshpeek.com".freeze
  s.extra_rdoc_files = ["LICENSE".freeze, "README.rdoc".freeze]
  s.files = ["LICENSE".freeze, "README.rdoc".freeze]
  s.homepage = "http://github.com/josh/rack-mount".freeze
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "Stackable dynamic tree based Rack router".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>.freeze, [">= 1.0.0"])
      s.add_development_dependency(%q<racc>.freeze, [">= 0"])
      s.add_development_dependency(%q<rexical>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rack>.freeze, [">= 1.0.0"])
      s.add_dependency(%q<racc>.freeze, [">= 0"])
      s.add_dependency(%q<rexical>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>.freeze, [">= 1.0.0"])
    s.add_dependency(%q<racc>.freeze, [">= 0"])
    s.add_dependency(%q<rexical>.freeze, [">= 0"])
  end
end
