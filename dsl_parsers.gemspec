$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dsl_parsers/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dsl_parsers"
  s.version     = DslParsers::VERSION
  s.authors     = ["Rudskikh Ivan"]
  s.email       = ["shredder-rull@yandex.ru"]
  s.homepage    = "https://github.com/shredder-rull/dsl_parsers"
  s.summary     = "DSL building parsers"
  s.description = "DSL building parsers"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]


  s.add_dependency "activesupport"
  s.add_dependency "nokogiri"

  s.add_development_dependency "pry"
  s.add_development_dependency "pry-doc"
  s.add_development_dependency "pry-nav"
  s.add_development_dependency "rspec", "~> 3.1.0"
  s.add_development_dependency "hirb-unicode"
  s.add_development_dependency "sqlite3"

end
