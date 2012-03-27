require "spec_helper"

describe "Dynamic Queues" do

  before(:each) do
    Resque.redis.flushall
  end

  context "basic resque behavior still works" do

    it "can work on multiple queues" do
      Resque::Job.create(:high, SomeJob)
      Resque::Job.create(:critical, SomeJob)

      worker = Resque::Worker.new(:critical, :high)

      worker.process
      Resque.size(:high).should == 1
      Resque.size(:critical).should == 0

      worker.process
      Resque.size(:high).should == 0
    end

    it "can work on all queues" do
      Resque::Job.create(:high, SomeJob)
      Resque::Job.create(:critical, SomeJob)
      Resque::Job.create(:blahblah, SomeJob)

      worker = Resque::Worker.new("*")

      worker.work(0)
      Resque.size(:high).should == 0
      Resque.size(:critical).should == 0
      Resque.size(:blahblah).should == 0
    end

    it "processes * queues in alphabetical order" do
      Resque::Job.create(:high, SomeJob)
      Resque::Job.create(:critical, SomeJob)
      Resque::Job.create(:blahblah, SomeJob)

      worker = Resque::Worker.new("*")

      worker.work(0) do |job|
        Resque.redis.rpush("processed_queues", job.queue)
      end

      Resque.redis.lrange("processed_queues", 0, -1).should == %w( high critical blahblah ).sort
    end

    it "should pass lint" do
      Resque::Plugin.lint(Resque::Plugins::DynamicQueues)
    end

  end

  context "attributes" do
    it "should always have a fallback pattern" do
      Resque.get_dynamic_queues.should == {'default' => ['*']}
    end
    
    it "should allow setting single patterns" do
      Resque.get_dynamic_queue('foo').should == ['*']
      Resque.set_dynamic_queue('foo', ['bar'])
      Resque.get_dynamic_queue('foo').should == ['bar']
    end
    
    it "should allow setting multiple patterns" do
      Resque.set_dynamic_queues({'foo' => ['bar'], 'baz' => ['boo']})
      Resque.get_dynamic_queues.should == {'foo' => ['bar'], 'baz' => ['boo'], 'default' => ['*']}
    end
    
    it "should remove mapping when setting empty value" do
      Resque.get_dynamic_queues
      Resque.set_dynamic_queues({'foo' => ['bar'], 'baz' => ['boo']})
      Resque.get_dynamic_queues.should == {'foo' => ['bar'], 'baz' => ['boo'], 'default' => ['*']}
      
      Resque.set_dynamic_queues({'foo' => [], 'baz' => ['boo']})
      Resque.get_dynamic_queues.should == {'baz' => ['boo'], 'default' => ['*']}
      Resque.set_dynamic_queues({'baz' => nil})
      Resque.get_dynamic_queues.should == {'default' => ['*']}
      
      Resque.set_dynamic_queues({'foo' => ['bar'], 'baz' => ['boo']})
      Resque.set_dynamic_queue('foo', [])
      Resque.get_dynamic_queues.should == {'baz' => ['boo'], 'default' => ['*']}
      Resque.set_dynamic_queue('baz', nil)
      Resque.get_dynamic_queues.should == {'default' => ['*']}
    end
    
    
  end
  
  context "basic queue patterns" do

    before(:each) do
      Resque.watch_queue("high_x")
      Resque.watch_queue("foo")
      Resque.watch_queue("high_y")
      Resque.watch_queue("superhigh_z")
    end

    it "can specify simple queues" do
      worker = Resque::Worker.new("foo")
      worker.queues.should == ["foo"]

      worker = Resque::Worker.new("foo", "bar")
      worker.queues.should == ["foo", "bar"]
    end

    it "can specify simple wildcard" do
      worker = Resque::Worker.new("*")
      worker.queues.should == ["foo", "high_x", "high_y", "superhigh_z"]
    end

    it "can include queues with pattern"do
      worker = Resque::Worker.new("high*")
      worker.queues.should == ["high_x", "high_y"]

      worker = Resque::Worker.new("*high_z")
      worker.queues.should == ["superhigh_z"]

      worker = Resque::Worker.new("*high*")
      worker.queues.should == ["high_x", "high_y", "superhigh_z"]
    end

    it "can blacklist queues" do
      worker = Resque::Worker.new("*", "!foo")
      worker.queues.should == ["high_x", "high_y", "superhigh_z"]
    end

    it "can blacklist dynamic queues" do
      Resque.set_dynamic_queue("mykey", ["foo"])
      worker = Resque::Worker.new("*", "!@mykey")
      worker.queues.should == ["high_x", "high_y", "superhigh_z"]
    end

    it "can blacklist queues with pattern" do
      worker = Resque::Worker.new("*", "!*high*")
      worker.queues.should == ["foo"]
    end

  end

  context "redis backed queues" do

    it "can dynamically lookup queues" do
      Resque.set_dynamic_queue("mykey", ["foo", "bar"])
      worker = Resque::Worker.new("@mykey")
      worker.queues.should == ["bar", "foo"]
    end

    it "will not bloat the workers queue" do
      Resque.watch_queue("high_x")
      worker = Resque::Worker.new("@mykey")

      worker.send(:instance_eval, "@queues").should == ['@mykey']
      worker.queues.should == ["high_x"]
      worker.send(:instance_eval, "@queues").should == ['@mykey']
      worker.queues.should == ["high_x"]
    end

    it "uses hostname as default key in dynamic queues" do
      host = `hostname`.chomp
      Resque.set_dynamic_queue(host, ["foo", "bar"])
      worker = Resque::Worker.new("@")
      worker.queues.should == ["bar", "foo"]
    end

    it "can use wildcards in dynamic queues" do
      Resque.watch_queue("high_x")
      Resque.watch_queue("foo")
      Resque.watch_queue("high_y")
      Resque.watch_queue("superhigh_z")

      Resque.set_dynamic_queue("mykey", ["*high*", "!high_y"])
      worker = Resque::Worker.new("@mykey")
      worker.queues.should == ["high_x", "superhigh_z"]
    end

    it "falls back to default queues when missing" do
      Resque.set_dynamic_queue("default", ["foo", "bar"])
      worker = Resque::Worker.new("@mykey")
      worker.queues.should == ["bar", "foo"]
    end

    it "falls back to all queues when missing and no default" do
      Resque.watch_queue("high_x")
      Resque.watch_queue("foo")
      worker = Resque::Worker.new("@mykey")
      worker.queues.should == ["foo", "high_x"]
    end

    it "falls back to all queues when missing and no default and keep up to date" do
      Resque.watch_queue("high_x")
      Resque.watch_queue("foo")
      worker = Resque::Worker.new("@mykey")
      worker.queues.should == ["foo", "high_x"]
      Resque.watch_queue("bar")
      worker.queues.should == ["bar", "foo", "high_x"]
    end

  end

end
