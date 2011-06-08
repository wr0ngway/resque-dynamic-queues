module Resque
  module Plugins
    module DynamicQueues
      module Attributes

        def get_dynamic_queue(key)
          queue_names = redis.lrange("dynamic_queue:#{key}", 0, -1)

          if queue_names.nil? || queue_names.size == 0
            queue_names = redis.lrange("dynamic_queue:default", 0, -1)
          end
          
          if queue_names.nil? || queue_names.size == 0
            queue_names = Resque.queues
          end

          return queue_names
        end

        def set_dynamic_queue(key, values)
          k = "dynamic_queue:#{key}"
          redis.del(k)
          Array(values).each do |v|
             redis.rpush(k, v)
          end
        end

        def get_dynamic_queues
          (redis.keys("dynamic_queue:*") || []).collect{|q| q.gsub('dynamic_queue:', '')}
        end

      end
    end
  end
end
