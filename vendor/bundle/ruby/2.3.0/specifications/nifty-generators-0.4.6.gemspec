# -*- encoding: utf-8 -*-
# stub: nifty-generators 0.4.6 ruby lib

Gem::Specification.new do |s|
  s.name = "nifty-generators".freeze
  s.version = "0.4.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.4".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ryan Bates".freeze]
  s.date = "2011-03-26"
  s.description = "A collection of useful Rails generator scripts for scaffolding, layout files, authentication, and more.".freeze
  s.email = "ryan@railscasts.com".freeze
  s.homepage = "http://github.com/ryanb/nifty-generators".freeze
  s.rubyforge_project = "nifty-generators".freeze
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "A collection of useful Rails generator scripts.".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec-rails>.freeze, ["~> 2.0.1"])
      s.add_development_dependency(%q<cucumber>.freeze, ["~> 0.9.2"])
      s.add_development_dependency(%q<rails>.freeze, ["~> 3.0.0"])
      s.add_development_dependency(%q<mocha>.freeze, ["~> 0.9.8"])
      s.add_development_dependency(%q<bcrypt-ruby>.freeze, ["~> 2.1.2"])
      s.add_development_dependency(%q<sqlite3-ruby>.freeze, ["~> 1.3.1"])
    else
      s.add_dependency(%q<rspec-rails>.freeze, ["~> 2.0.1"])
      s.add_dependency(%q<cucumber>.freeze, ["~> 0.9.2"])
      s.add_dependency(%q<rails>.freeze, ["~> 3.0.0"])
      s.add_dependency(%q<mocha>.freeze, ["~> 0.9.8"])
      s.add_dependency(%q<bcrypt-ruby>.freeze, ["~> 2.1.2"])
      s.add_dependency(%q<sqlite3-ruby>.freeze, ["~> 1.3.1"])
    end
  else
    s.add_dependency(%q<rspec-rails>.freeze, ["~> 2.0.1"])
    s.add_dependency(%q<cucumber>.freeze, ["~> 0.9.2"])
    s.add_dependency(%q<rails>.freeze, ["~> 3.0.0"])
    s.add_dependency(%q<mocha>.freeze, ["~> 0.9.8"])
    s.add_dependency(%q<bcrypt-ruby>.freeze, ["~> 2.1.2"])
    s.add_dependency(%q<sqlite3-ruby>.freeze, ["~> 1.3.1"])
  end
end
