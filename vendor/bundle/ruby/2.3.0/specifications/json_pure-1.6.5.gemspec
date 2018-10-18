# -*- encoding: utf-8 -*-
# stub: json_pure 1.6.5 ruby lib

Gem::Specification.new do |s|
  s.name = "json_pure".freeze
  s.version = "1.6.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "2012-01-15"
  s.description = "This is a JSON implementation in pure Ruby.".freeze
  s.email = "flori@ping.de".freeze
  s.extra_rdoc_files = ["README.rdoc".freeze]
  s.files = ["README.rdoc".freeze]
  s.homepage = "http://flori.github.com/json".freeze
  s.rdoc_options = ["--title".freeze, "JSON implemention for ruby".freeze, "--main".freeze, "README.rdoc".freeze]
  s.rubyforge_project = "json".freeze
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "JSON Implementation for Ruby".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<permutation>.freeze, [">= 0"])
      s.add_development_dependency(%q<bullshit>.freeze, [">= 0"])
      s.add_development_dependency(%q<sdoc>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 0.9.2"])
    else
      s.add_dependency(%q<permutation>.freeze, [">= 0"])
      s.add_dependency(%q<bullshit>.freeze, [">= 0"])
      s.add_dependency(%q<sdoc>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, ["~> 0.9.2"])
    end
  else
    s.add_dependency(%q<permutation>.freeze, [">= 0"])
    s.add_dependency(%q<bullshit>.freeze, [">= 0"])
    s.add_dependency(%q<sdoc>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 0.9.2"])
  end
end
