# -*- encoding: utf-8 -*-
# stub: ftw 0.0.44 ruby lib lib

Gem::Specification.new do |s|
  s.name = "ftw"
  s.version = "0.0.44"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib", "lib"]
  s.authors = ["Jordan Sissel"]
  s.date = "2015-06-19"
  s.description = "For The Web. Trying to build a solid and sane API for client and server web stuff. Client and Server operations for HTTP, WebSockets, SPDY, etc."
  s.email = ["jls@semicomplete.com"]
  s.homepage = "http://github.com/jordansissel/ruby-ftw"
  s.licenses = ["Apache License (2.0)"]
  s.rubygems_version = "2.4.6"
  s.summary = "For The Web. Trying to build a solid and sane API for client and server web stuff. Client and Server operations for HTTP, WebSockets, SPDY, etc."

  s.installed_by_version = "2.4.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<cabin>, ["> 0"])
      s.add_runtime_dependency(%q<http_parser.rb>, ["~> 0.6"])
      s.add_runtime_dependency(%q<addressable>, [">= 0"])
      s.add_runtime_dependency(%q<backports>, [">= 2.6.2"])
      s.add_development_dependency(%q<minitest>, ["> 0"])
    else
      s.add_dependency(%q<cabin>, ["> 0"])
      s.add_dependency(%q<http_parser.rb>, ["~> 0.6"])
      s.add_dependency(%q<addressable>, [">= 0"])
      s.add_dependency(%q<backports>, [">= 2.6.2"])
      s.add_dependency(%q<minitest>, ["> 0"])
    end
  else
    s.add_dependency(%q<cabin>, ["> 0"])
    s.add_dependency(%q<http_parser.rb>, ["~> 0.6"])
    s.add_dependency(%q<addressable>, [">= 0"])
    s.add_dependency(%q<backports>, [">= 2.6.2"])
    s.add_dependency(%q<minitest>, ["> 0"])
  end
end
