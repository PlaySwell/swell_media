$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "swell_media/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "swell_media"
  s.version     = SwellMedia::VERSION
  s.authors     = ["Gk Parish-Philp", "Michael Ferguson"]
  s.email       = ["gk@playswell.com"]
  s.homepage    = "http://playswell.com"
  s.summary     = "TODO: Summary of SwellMedia."
  s.description = "TODO: Description of SwellMedia."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "acts-as-taggable-on"
  s.add_dependency "awesome_nested_set", '~> 3.0.0.rc.3'
  s.add_dependency "cancan"
  s.add_dependency "devise"
  s.add_dependency "friendly_id", '~> 5.0.0'
  s.add_dependency "haml"
  s.add_dependency "kaminari"
  # TODO s.add_dependency 'paper_trail', '~> 3.0.1'

  s.add_dependency "rails", "~> 4.0.4"

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency "sqlite3"
end
