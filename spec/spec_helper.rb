require 'rspec'
require 'resque-dynamic-queues'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
end

# No need to start redis when running in Travis
unless ENV['CI']

  begin
    Resque.queues
  rescue Errno::ECONNREFUSED
    spec_dir = File.dirname(File.expand_path(__FILE__))
    REDIS_CMD = "redis-server #{spec_dir}/redis-test.conf"

    puts "Starting redis for testing at localhost..."
    puts `cd #{spec_dir}; #{REDIS_CMD}`

    # Schedule the redis server for shutdown when tests are all finished.
    at_exit do
      puts 'Stopping redis'
      pid = File.read("#{spec_dir}/redis.pid").to_i rescue nil
      system ("kill -9 #{pid}") if pid.to_i != 0
      File.delete("#{spec_dir}/redis.pid") rescue nil
      File.delete("#{spec_dir}/redis-server.log") rescue nil
      File.delete("#{spec_dir}/dump.rdb") rescue nil
    end
  end

end

class SomeJob
  def self.perform(*args)
  end
end
