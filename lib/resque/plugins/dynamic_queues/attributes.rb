module Resque
  module Plugins
    module DynamicQueues
      module Attributes

        def get_dynamic_queue(key)
          redis.lrange("dynamic_queue:#{key}", 0, -1)
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
