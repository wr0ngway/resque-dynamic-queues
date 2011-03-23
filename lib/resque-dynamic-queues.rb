require 'resque'
require 'resque/worker'
require 'resque/plugins/dynamic_queues/attributes'
require 'resque/plugins/dynamic_queues/queues'

#module Resque
#  extend Resque::Plugins::DynamicQueues::Attributes
#end
Resque.send(:extend, Resque::Plugins::DynamicQueues::Attributes)
Resque::Worker.send(:include, Resque::Plugins::DynamicQueues::Queues)
