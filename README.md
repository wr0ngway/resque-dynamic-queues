A resque plugin for specifying the queues a worker pulls from with wildcards, negations, or dynamic look up from redis.

Authored against Resque 1.15, so it at least works with that - try running the tests if you use a different version of resque

Usage:

If creating a gem of your own that uses resque-dynamic-queues, you may have to add an explicit require statement at the top of your Rakefile:

    require 'resque-dynamic-queues'

Start your workers with a QUEUE that can contain '\*' for zero-or more of any character, '!' to exclude the following pattern, or @key to look up the patterns from redis.  Some examples help:

    QUEUE='foo' rake resque:work

Pulls jobs from the queue 'foo'

    QUEUE='*' rake resque:work

Pulls jobs from any queue

    QUEUE='*foo' rake resque:work

Pulls jobs from queues that end in foo

    QUEUE='*foo*' rake resque:work

Pulls jobs from queues whose names contain foo

    QUEUE='*foo*,!foobar' rake resque:work

Pulls jobs from queues whose names contain foo except the foobar queue

    QUEUE='*foo*,!*bar' rake resque:work

Pulls jobs from queues whose names contain foo except queues whose names end in bar

    QUEUE='@key' rake resque:work

Pulls jobs from queue names stored in redis (use Resque.set\_dynamic\_queue("key", ["queuename1", "queuename2"]) to set them)

    QUEUE='*,!@key' rake resque:work

Pulls jobs from any queue execept ones stored in redis

    QUEUE='@' rake resque:work

Pulls jobs from queue names stored in redis using the hostname of the worker

    Resque.set_dynamic_queue("key", ["*foo*", "!*bar"])
    QUEUE='@key' rake resque:work

Pulls jobs from queue names stored in redis, with wildcards/negations

    task :custom_worker do
      ENV['QUEUE'] = "*foo*,!*bar"
      Rake::Task['resque:work'].invoke
    end

From a custom rake script


There is also a tab in the resque-web UI that allows you to define the dynamic queues  To activate it, you need to require 'resque-dynamic-queues-server' in whatever initializer you use to bring up resque-web.


Contributors:

Matt Conway ( https://github.com/wr0ngway )
Bert Goethals ( https://github.com/Bertg )
