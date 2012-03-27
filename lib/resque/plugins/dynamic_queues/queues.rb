module Resque
  module Plugins
    module DynamicQueues
      module Queues

        # Returns a list of queues to use when searching for a job.
        #
        # A splat ("*") means you want every queue (in alpha order) - this
        # can be useful for dynamically adding new queues.
        #
        # The splat can also be used as a wildcard within a queue name,
        # e.g. "*high*", and negation can be indicated with a prefix of "!"
        #
        # An @key can be used to dynamically look up the queue list for key from redis.
        # If no key is supplied, it defaults to the worker's hostname, and wildcards
        # and negations can be used inside this dynamic queue list.   Set the queue
        # list for a key with Resque.set_dynamic_queue(key, ["q1", "q2"]
        #
        def queues_with_dynamic
          queue_names = @queues.dup

          return queues_without_dynamic if queue_names.grep(/(^!)|(^@)|(\*)/).size == 0

          real_queues = Resque.queues
          matched_queues = []

          while q = queue_names.shift
            q = q.to_s

            if q =~ /^(!)?@(.*)/
              key = $2.strip
              key = hostname if key.size == 0

              add_queues = Resque.get_dynamic_queue(key)
              add_queues.map! { |q| '!' + q } if $1

              queue_names.concat(add_queues)
              next
            end

            if q =~ /^!/
              negated = true
              q = q[1..-1]
            end

            patstr = q.gsub(/\*/, ".*")
            pattern = /^#{patstr}$/
            if negated
              matched_queues -= matched_queues.grep(pattern)
            else
              matches = real_queues.grep(/^#{pattern}$/)
              matches = [q] if matches.size == 0 && q == patstr
              matched_queues.concat(matches)
            end
          end

          return matched_queues.uniq.sort
        end


        def self.included(receiver)
          receiver.class_eval do
            alias queues_without_dynamic queues
            alias queues queues_with_dynamic
          end
        end

      end
    end
  end
end
