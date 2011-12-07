module Resque
  module Plugins
    module DynamicQueues

      KEY_PREFIX = "dynamic_queue"
      FALLBACK_KEY = "default"

      module Attributes

        def get_dynamic_queue(key)
          queue_names = redis.lrange("#{KEY_PREFIX}:#{key}", 0, -1)

          if queue_names.nil? || queue_names.size == 0
            queue_names = redis.lrange("#{KEY_PREFIX}:#{FALLBACK_KEY}", 0, -1)
          end
          
          if queue_names.nil? || queue_names.size == 0
            queue_names = Resque.queues
          end

          return queue_names
        end

        def set_dynamic_queue(key, values)
          k = "#{KEY_PREFIX}:#{key}"
          redis.multi do
            redis.del(k)
            Array(values).each do |v|
               redis.rpush(k, v)
            end
          end
        end

        def get_dynamic_queues
          dqueues = redis.keys("#{KEY_PREFIX}:*") || []
          dqueues = dqueues.collect{|q| q.gsub('dynamic_queue:', '')}
          dqueues << FALLBACK_KEY unless dqueues.include?(FALLBACK_KEY)
          return dqueues
        end

      end
    end
  end
end
