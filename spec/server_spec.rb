ENV['RACK_ENV'] = 'test'

require 'spec_helper'
require 'rack'
require 'rack/test'
require 'resque/server'
require 'resque_dynamic_queues_server'

Sinatra::Base.set :environment, :test
# ::Test::Unit::TestCase.send :include, Rack::Test::Methods


describe "Dynamic Queues pages" do
  include Rack::Test::Methods

  def app
    @app ||= Resque::Server.new
  end

  before(:each) do
    Resque.redis.flushall
  end

  context "existnce in application" do

    it "should respond to it's url" do
      get "/dynamic_queues"
      last_response.should be_ok
    end

    it "should display its tab" do
      get "/overview"
      last_response.body.should include "<a href='/dynamicqueues'>DynamicQueues</a>"
    end

  end

  context "show dynamic queues table" do

    it "should shows names of queues" do
      Resque.set_dynamic_queue("key_one", ["foo"])
      Resque.set_dynamic_queue("key_two", ["bar"])

      get "/dynamic_queues"

      last_response.body.should include 'key_one'
      last_response.body.should include 'key_two'
    end

    it "should shows values of queues" do
      Resque.set_dynamic_queue("key_one", ["foo"])
      Resque.set_dynamic_queue("key_two", ["bar", "baz"])

      get "/dynamic_queues"

      last_response.body.should include 'foo'
      last_response.body.should include 'bar, baz'
    end

  end

  context "form to edit queues" do

    it "should have form to edit queues" do
      get "/dynamic_queues"

      last_response.body.should match /<form .*>/
      last_response.body.should match /<input .*name=['"]name['"].*>/
      last_response.body.should match /<textarea .*name=['"]queues['"].*>/
    end

    it "should delete queues on empty queue submit" do
      Resque.set_dynamic_queue("key_two", ["bar", "baz"])
      post "/dynamic_queues", {'name' => "key_two", "queues" => ""}

      Resque.get_dynamic_queue("key_two").should be_empty
    end

    it "should create queues" do
      post "/dynamic_queues", {'name' => "key_two", "queues" => "foo\n\rbar\n\rbaz"}

      Resque.get_dynamic_queue("key_two").should == %w{foo bar baz}
    end

    it "should update queues" do
      Resque.set_dynamic_queue("key_two", ["bar", "baz"])
      post "/dynamic_queues", {'name' => "key_two", "queues" => "foo\n\rbar\n\rbaz"}

      Resque.get_dynamic_queue("key_two").should == %w{foo bar baz}
    end

  end

end