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

      end
    end
  end
end
