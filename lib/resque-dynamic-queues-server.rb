require 'resque-dynamic-queues'
require 'resque/plugins/dynamic_queues/server'

Resque::Server.register Resque::Plugins::DynamicQueues::Server
