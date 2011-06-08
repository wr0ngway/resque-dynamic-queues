ENV['RACK_ENV'] = 'test'

require 'spec_helper'
require 'rack'
require 'rack/test'
require 'resque/server'
require 'resque-dynamic-queues-server'

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
      get "/dynamicqueues"
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

      get "/dynamicqueues"

      last_response.body.should include 'key_one'
      last_response.body.should include 'key_two'
    end

    it "should shows values of queues" do
      Resque.set_dynamic_queue("key_one", ["foo"])
      Resque.set_dynamic_queue("key_two", ["bar", "baz"])

      get "/dynamicqueues"

      last_response.body.should include 'foo'
      last_response.body.should include 'bar, baz'
    end

  end

  context "remove queue link" do


    it "should shows remove link for queue" do
      Resque.set_dynamic_queue("key_one", ["foo"])

      get "/dynamicqueues"

      last_response.body.should match /<a .*href=['"]http:\/\/example.org\/dynamicqueues\/key_one\/remove['"].*>/
    end

    it "should remove queue when remove link clicked" do # JS will do the post
      Resque.set_dynamic_queue("key_one", ["foo"])

      post "/dynamicqueues/key_one/remove"

      last_response.should be_redirect
      last_response['Location'].should match /dynamicqueues/
      Resque.get_dynamic_queue("key_two").should be_empty
    end

  end

  context "form to edit queues" do

    it "should have form to edit queues" do
      get "/dynamicqueues"

      last_response.body.should match /<form .*action=['"]http:\/\/example.org\/dynamicqueues['"].*>/
      last_response.body.should match /<input .*name=['"]name['"].*>/
      last_response.body.should match /<textarea .*name=['"]queues['"].*>/
    end

    it "should delete queues on empty queue submit" do
      Resque.set_dynamic_queue("key_two", ["bar", "baz"])
      post "/dynamicqueues", {'name' => "key_two", "queues" => ""}

      last_response.should be_redirect
      last_response['Location'].should match /dynamicqueues/
      Resque.get_dynamic_queue("key_two").should be_empty
    end

    it "should create queues" do
      post "/dynamicqueues", {'name' => "key_two", "queues" => "foo\n\rbar\n\rbaz"}

      last_response.should be_redirect
      last_response['Location'].should match /dynamicqueues/
      Resque.get_dynamic_queue("key_two").should == %w{foo bar baz}
    end

    it "should update queues" do
      Resque.set_dynamic_queue("key_two", ["bar", "baz"])
      post "/dynamicqueues", {'name' => "key_two", "queues" => "foo\n\rbar\n\rbaz"}

      last_response.should be_redirect
      last_response['Location'].should match /dynamicqueues/
      Resque.get_dynamic_queue("key_two").should == %w{foo bar baz}
    end

  end

end