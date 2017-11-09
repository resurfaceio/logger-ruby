# resurfaceio-logger-ruby
&copy; 2016-2017 Resurface Labs LLC

This gem makes it easy to log actual usage of Ruby web/json apps.

[![Gem Version](https://badge.fury.io/rb/resurfaceio-logger.svg)](https://badge.fury.io/rb/resurfaceio-logger)

## Contents

<ul>
<li><a href="#dependencies">Dependencies</a></li>
<li><a href="#installing_with_bundler">Installing With Bundler</a></li>
<li><a href="#logging_from_rails_controller">Logging From Rails Controller</a></li>
<li><a href="#logging_from_rack_middleware">Logging From Rack Middleware</a></li>
<li><a href="#logging_from_sinatra">Logging From Sinatra</a></li>
<li><a href="#advanced_topics">Advanced Topics</a><ul>
<li><a href="#setting_default_url">Setting Default URL</a></li>
<li><a href="#enabling_and_disabling">Enabling and Disabling Loggers</a></li>
<li><a href="#logging_api">Logging API</a></li>
</ul></li>
</ul>

<a name="dependencies"/>

## Dependencies

Requires Ruby 2.x. No other dependencies to conflict with your app.

<a name="installing_with_bundler"/>

## Installing With Bundler

Add this line to your Gemfile:

```ruby
gem 'resurfaceio-logger'
```

Then install with Bundler: `bundle install`

<a name="logging_from_rails_controller"/>

## Logging From Rails Controller

After <a href="#installing_with_bundler">installing the gem</a>, add an `around_action` to your Rails controller.

```ruby
require 'resurfaceio/all'

class MyController < ApplicationController
  around_action HttpLoggerForRails.new(url: 'https://my-logging-url')
end
```

<a name="logging_from_rack_middleware"/>

## Logging From Rack Middleware

After <a href="#installing_with_bundler">installing the gem</a>, add these lines below to `config.ru`, before the final
'run' statement.

```ruby
require 'resurfaceio/all'
use HttpLoggerForRack, url: 'https://my-logging-url'
run <...>
```

<a name="logging_from_sinatra"/>

## Logging From Sinatra

After <a href="#installing_with_bundler">installing the gem</a>, create a logger and call it from the routes of interest.

```ruby
require 'sinatra'
require 'resurfaceio/all'

logger = HttpLogger.new(url: 'https://my-logging-url')

get '/' do
  response_body = '<html>Hello World</html>'
  logger.log request, response, response_body
  response_body
end

post '/' do
  status 401
  logger.log request, response
  ''
end
```

<a name="advanced_topics"/>

## Advanced Topics

<a name="setting_default_url"/>

### Setting Default URL

Set the `USAGE_LOGGERS_URL` environment variable to provide a default value whenever the URL is not specified.

```ruby
# from command line
export USAGE_LOGGERS_URL="https://my-logging-url"

# in config.ru
ENV['USAGE_LOGGERS_URL']='https://my-logging-url'

# for Heroku app
heroku config:set USAGE_LOGGERS_URL=https://my-logging-url
```

Loggers look for this environment variable when no URL is provided.

```ruby
# for basic logger
logger = HttpLogger.new

# in rails controller
around_action HttpLoggerForRails.new

# in rack middleware
use HttpLoggerForRack
```

<a name="enabling_and_disabling"/>

### Enabling and Disabling Loggers

Individual loggers can be controlled through their `enable` and `disable` methods. When disabled, loggers will
not send any logging data, and the result returned by the `log` method will always be true (success).

All loggers for an application can be enabled or disabled at once with the `UsageLoggers` class. This even controls
loggers that have not yet been created by the application.

```ruby
UsageLoggers.disable       # disable all loggers
UsageLoggers.enable        # enable all loggers
```

All loggers can be permanently disabled with the `USAGE_LOGGERS_DISABLE` environment variable. When set to true,
loggers will never become enabled, even if `UsageLoggers.enable` is called by the application. This is primarily 
done by automated tests to disable all logging even if other control logic exists. 

```ruby
# from command line
export USAGE_LOGGERS_DISABLE="true"

# in config.ru
ENV['USAGE_LOGGERS_DISABLE']='true'

# for Heroku app
heroku config:set USAGE_LOGGERS_DISABLE=true
```

<a name="logging_api"/>

### Logging API

Loggers can be directly integrated into your application with this API, which gives complete control over how
usage logging is implemented.

```ruby
require 'resurfaceio/all'

# create and configure logger
logger = HttpLogger.new(my_https_url)                            # log to remote url
logger = HttpLogger.new(url: my_https_url, enabled: false)       # (initially disabled)
logger = HttpLogger.new(queue: my_queue)                         # log to appendable list
logger = HttpLogger.new(queue: my_queue, enabled: false)         # (initially disabled)
logger.disable                                                   # disable this logger
logger.enable                                                    # enable this logger
if logger.enabled? ...                                           # test if this enabled

# define request to log
request = HttpRequestImpl.new
request.body = 'some json'
request.content_type = 'application/json'
request.headers['A'] = '123'
request.request_method = 'GET'
request.url = 'http://google.com'

# define response to log
response = HttpResponseImpl.new
response.body = 'some html'
response.content_type = 'text/html'
response.headers['B'] = '234'
response.status = 200

# log objects defined above
logger.log request, response

# log with overriden request/response bodies
logger.log request, response, 'my-response-body', 'my-request-body'

# submit a custom message (destination may accept or not)
logger.submit '...'
```
