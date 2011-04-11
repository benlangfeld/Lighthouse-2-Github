# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lh2gh/version"

Gem::Specification.new do |s|
  s.name        = "lh2gh"
  s.version     = Lh2gh::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Langfeld"]
  s.email       = ["ben@langfeld.me"]
  s.homepage    = "http://langfeld.me"
  s.summary     = %q{Move from Lighthouse to Github Issues}
  s.description = %q{Export all of your tickets from Lighthouse to Github issues in one fell swoop.}

  s.rubyforge_project = "lh2gh"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.9.2'

  s.add_dependency 'thor'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
end
