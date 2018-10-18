# -*- encoding: utf-8 -*-
# stub: on_the_spot 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "on_the_spot".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nathan Van der Auwera".freeze]
  s.date = "2012-01-25"
  s.description = "Unobtrusive in place editing, using jEditable; only works in Rails 3".freeze
  s.email = "nathan@dixis.com".freeze
  s.extra_rdoc_files = ["LICENSE".freeze, "README.markdown".freeze]
  s.files = ["LICENSE".freeze, "README.markdown".freeze]
  s.homepage = "http://github.com/nathanvda/on_the_spot".freeze
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "unobtrusive in place editing".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>.freeze, [">= 2.0.0rc"])
      s.add_development_dependency(%q<actionpack>.freeze, [">= 3.0.0"])
      s.add_runtime_dependency(%q<json_pure>.freeze, [">= 1.4.6"])
    else
      s.add_dependency(%q<rspec>.freeze, [">= 2.0.0rc"])
      s.add_dependency(%q<actionpack>.freeze, [">= 3.0.0"])
      s.add_dependency(%q<json_pure>.freeze, [">= 1.4.6"])
    end
  else
    s.add_dependency(%q<rspec>.freeze, [">= 2.0.0rc"])
    s.add_dependency(%q<actionpack>.freeze, [">= 3.0.0"])
    s.add_dependency(%q<json_pure>.freeze, [">= 1.4.6"])
  end
end
