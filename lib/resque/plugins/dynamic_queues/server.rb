require 'resque-dynamic-queues'

module Resque
  module Plugins
    module DynamicQueues
      module Server

        VIEW_PATH = File.join(File.dirname(__FILE__), 'server', 'views')

        def self.registered(app)
          app.get "/dynamicqueues" do
            @queues = []
            dqueues = Resque.get_dynamic_queues
            dqueues.each do |k, v|
              view_data = {
                  'name' => k,
                  'value' => Array(v).join(", "),
                  'expanded' => Resque::Worker.new("@#{k}").queues.join(", ")
              }
              @queues << view_data
            end
            
            @queues.sort! do |a, b|
              an = a['name']
              bn = b['name']
              if an == 'default'
                1
              elsif bn == 'default'
                -1
              else
                an <=> bn
              end
            end
            
            dynamicqueues_view :queues
          end

          app.post "/dynamicqueues" do
            dynamic_queues = Array(params['queues'])
            queues = {}
            dynamic_queues.each do |queue|
              key = queue['name']
              values = queue['value'].to_s.split(',').collect{|q| q.gsub(/\s/, '') }
              queues[key] = values
            end
            Resque.set_dynamic_queues(queues)
            redirect url(:dynamicqueues)
          end

          app.helpers do
            def dynamicqueues_view(filename, options = {}, locals = {})
              erb(File.read(File.join(::Resque::Plugins::DynamicQueues::Server::VIEW_PATH, "#{filename}.erb")), options, locals)
            end
          end

          app.tabs << "DynamicQueues"
        end
      end
    end
  end
end
