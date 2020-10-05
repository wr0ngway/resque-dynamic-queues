# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'resque/plugins/dynamic_queues/version'


Gem::Specification.new do |s|
  s.name        = "resque-dynamic-queues"
  s.version     = Resque::Plugins::DynamicQueues::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Conway"]
  s.email       = ["matt@conwaysplace.com"]
  s.homepage    = ""
  s.summary     = %q{A resque plugin for specifying the queues a worker pulls from with wildcards, negations, or dynamic look up from redis}
  s.description = %q{A resque plugin for specifying the queues a worker pulls from with wildcards, negations, or dynamic look up from redis}

  s.rubyforge_project = "resque-dynamic-queues"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("resque", '~> 1.10', '< 3')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', '~> 2.5')
  s.add_development_dependency('rack-test', '~> 0.5.4')

  # Needed for testing newer resque on ruby 1.8.7
  s.add_development_dependency('json')

end

