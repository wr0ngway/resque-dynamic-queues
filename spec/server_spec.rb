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

    it "should shows default queue when nothing set" do
      get "/dynamicqueues"

      last_response.body.should include 'default'
    end

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

    it "should show remove link for queue" do
      Resque.set_dynamic_queue("key_one", ["foo"])

      get "/dynamicqueues"

      last_response.body.should match /<a .*href=['"]#remove['"].*>/
    end

    it "should show add link" do
      get "/dynamicqueues"

      last_response.body.should match /<a .*href=['"]#add['"].*>/
    end

  end

  context "form to edit queues" do

    it "should have form to edit queues" do
      get "/dynamicqueues"

      last_response.body.should match /<form action="\/dynamicqueues"/
    end
    
    it "should show input fields" do
      Resque.set_dynamic_queue("key_one", ["foo"])
      Resque.set_dynamic_queue("key_two", ["bar", "baz"])
      get "/dynamicqueues"

      last_response.body.should match /<input type="text" id="input-0-name" name="queues\[\]\[name\]" value="key_one"/
      last_response.body.should match /<input type="text" id="input-0-value" name="queues\[\]\[value\]" value="foo"/
      last_response.body.should match /<input type="text" id="input-1-name" name="queues\[\]\[name\]" value="key_two"/
      last_response.body.should match /<input type="text" id="input-1-value" name="queues\[\]\[value\]" value="bar, baz"/
    end

    it "should delete queues on empty queue submit" do
      Resque.set_dynamic_queue("key_two", ["bar", "baz"])
      post "/dynamicqueues", {'queues' => [{'name' => "key_two", "value" => ""}]}

      last_response.should be_redirect
      last_response['Location'].should match /dynamicqueues/
      Resque.get_dynamic_queue("key_two", []).should be_empty
    end

    it "should create queues" do
      post "/dynamicqueues", {'queues' => [{'name' => "key_two", "value" => " foo, bar ,baz "}]}

      last_response.should be_redirect
      last_response['Location'].should match /dynamicqueues/
      Resque.get_dynamic_queue("key_two").should == %w{foo bar baz}
    end

    it "should update queues" do
      Resque.set_dynamic_queue("key_two", ["bar", "baz"])
      post "/dynamicqueues", {'queues' => [{'name' => "key_two", "value" => "foo,bar,baz"}]}

      last_response.should be_redirect
      last_response['Location'].should match /dynamicqueues/
      Resque.get_dynamic_queue("key_two").should == %w{foo bar baz}
    end

  end

end
