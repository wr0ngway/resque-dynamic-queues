require 'resque_dynamic_queues'

module Resque
  module Plugins
    module DynamicQueues
      module Server

        VIEW_PATH = File.join(File.dirname(__FILE__), 'server', 'views')

        def self.registered(app)
          app.get "/dynamicqueues" do
            @queues = Resque.get_dynamic_queues
            dq_view :queues
          end

          app.post "/dynamicqueues" do
            key    = params['name']
            values = params['queues'].to_s.split.collect{|q| q.gsub(/\s/, '')}
            Resque.set_dynamic_queue(key, values)
            redirect url(:dynamicqueues)
          end

          app.post "/dynamicqueues/:key/remove" do
            key    = params['key']
            Resque.set_dynamic_queue(key, [])
            redirect url(:dynamicqueues)
          end

          app.helpers do
            def dq_view(filename, options = {}, locals = {})
              erb(File.read(File.join(::Resque::Plugins::DynamicQueues::Server::VIEW_PATH, "#{filename}.erb")), options, locals)
            end
          end

          app.tabs << "DynamicQueues"
        end
      end
    end
  end
end

Resque::Server.register Resque::Plugins::DynamicQueues::Server
