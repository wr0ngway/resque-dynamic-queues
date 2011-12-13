module Resque
  module Plugins
    module DynamicQueues

      DYNAMIC_QUEUE_KEY = "dynamic_queue"
      FALLBACK_KEY = "default"

      module Attributes

        def get_dynamic_queue(key, fallback=['*'])
          data = redis.hget(DYNAMIC_QUEUE_KEY, key)
          queue_names = Resque.decode(data)

          if queue_names.nil? || queue_names.size == 0
            data = redis.hget(DYNAMIC_QUEUE_KEY, FALLBACK_KEY)
            queue_names = Resque.decode(data)
          end
          
          if queue_names.nil? || queue_names.size == 0
            queue_names = fallback
          end

          return queue_names
        end

        def set_dynamic_queue(key, values)
          if values.nil? or values.size == 0
            redis.hdel(DYNAMIC_QUEUE_KEY, key)
          else
            redis.hset(DYNAMIC_QUEUE_KEY, key, Resque.encode(values))
          end
        end
        
        def set_dynamic_queues(dynamic_queues)
          redis.multi do
            redis.del(DYNAMIC_QUEUE_KEY)
            dynamic_queues.each do |k, v|
              set_dynamic_queue(k, v)
            end
          end
        end

        def get_dynamic_queues
          result = {}
          queues = redis.hgetall(DYNAMIC_QUEUE_KEY)
          queues.each {|k, v| result[k] = Resque.decode(v) }
          result[FALLBACK_KEY] ||= ['*']
          return result
        end

      end
    end
  end
end
