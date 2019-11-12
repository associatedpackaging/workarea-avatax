$:.push File.expand_path("../lib", __FILE__)

require "workarea/avatax/version"

Gem::Specification.new do |s|
  s.name        = "workarea-avatax"
  s.version     = Workarea::Avatax::VERSION
  s.authors     = ["Eric Pigeon"]
  s.email       = ["epigeon@workarea.com"]
  s.summary     = "Avalara Tax Plugin for the Workarea Ecommerce Platform"
  s.description = "Avatax is a service for sales tax calculation and compliance"
  s.license     = "MIT"
  s.files       = `git ls-files`.split("\n")

  s.required_ruby_version = ">= 2.2.2"

  s.add_dependency "workarea", "~> 3.x", ">= 3.2"
  s.add_dependency "avatax", "~> 17.0"
  s.add_dependency "hashie", "~> 3.0"
end
