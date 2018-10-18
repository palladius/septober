# -*- encoding: utf-8 -*-
# stub: actionmailer 3.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "actionmailer".freeze
  s.version = "3.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2010-11-16"
  s.description = "Email on Rails. Compose, deliver, receive, and test emails using the familiar controller/view pattern. First-class support for multipart email and attachments.".freeze
  s.email = "david@loudthinking.com".freeze
  s.homepage = "http://www.rubyonrails.org".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7".freeze)
  s.requirements = ["none".freeze]
  s.rubyforge_project = "actionmailer".freeze
  s.rubygems_version = "2.5.2.3".freeze
  s.summary = "Email composition, delivery, and receiving framework (part of Rails).".freeze

  s.installed_by_version = "2.5.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<actionpack>.freeze, ["= 3.0.3"])
      s.add_runtime_dependency(%q<mail>.freeze, ["~> 2.2.9"])
    else
      s.add_dependency(%q<actionpack>.freeze, ["= 3.0.3"])
      s.add_dependency(%q<mail>.freeze, ["~> 2.2.9"])
    end
  else
    s.add_dependency(%q<actionpack>.freeze, ["= 3.0.3"])
    s.add_dependency(%q<mail>.freeze, ["~> 2.2.9"])
  end
end
