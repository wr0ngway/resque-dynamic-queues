require 'resque-dynamic-queues'

module Resque
  module PLugins
    module DynamicQueues
      module Server

        VIEW_PATH = File.join(File.dirname(__FILE__), 'server', 'views')

        def self.registered(app)

          app.get "/dynamic_queues" do
            @queues = Resque.get_dynamic_queues
            dq_view :queues
          end

          app.post "/dynamic_queues" do
            key    = params['name']
            values = params['queues'].split.collect{|q| q.gsub(/\s/, '')}
            Resque.set_dynamic_queue(key, values)
            redirect url(:dynamic_queues)
          end

          app.post "/dynamic_queues/:key/kill" do
            key    = params['key']
            Resque.set_dynamic_queue(key, [])
            redirect url(:dynamic_queues)
          end

          app.helpers do
            def dq_view(filename, options = {}, locals = {})
              erb(File.read(File.join(::Resque::DynamicQueueServer::VIEW_PATH, "#{filename}.erb")), options, locals)
            end
          end

          app.tabs << "DynamicQueues"
        end
      end
    end
  end
end

Resque::Server.register Resque::PLugins::DynamicQueues::Server
