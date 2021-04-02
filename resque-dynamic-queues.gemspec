# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'resque/plugins/dynamic_queues/version'

Gem::Specification.new do |s|
  s.name        = "resque-dynamic-queues"
  s.version     = Resque::Plugins::DynamicQueues::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Conway", "Alistair McKinnell"]
  s.email       = ["matt@conwaysplace.com", "alistairm@nulogy.com"]
  s.homepage    = "https://github.com/nulogy/resque-dynamic-queues"
  s.summary     = %q{A resque plugin for specifying the queues a worker pulls from with wildcards, negations, or dynamic look up from redis}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("resque", "~> 2.0", "< 3")

  s.add_development_dependency("rake", "~> 13.0")
  s.add_development_dependency("rspec", "~> 3.10")
  s.add_development_dependency("rack-test", "~> 1.0")
end

