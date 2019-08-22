# resurfaceio-logger-ruby
Logging usage of Ruby-based services, with user privacy by design.

Visit <a href="https://resurface.io">resurface.io</a> for general information on usage logging.

[![Gem Version](https://badge.fury.io/rb/resurfaceio-logger.svg)](https://badge.fury.io/rb/resurfaceio-logger)

## Contents

<ul>
<li><a href="#dependencies">Dependencies</a></li>
<li><a href="#installing_with_bundler">Installing With Bundler</a></li>
<li><a href="#logging_from_rails_controller">Logging From Rails Controller</a></li>
<li><a href="#logging_from_rack_middleware">Logging From Rack Middleware</a></li>
<li><a href="#logging_from_sinatra">Logging From Sinatra</a></li>
<li><a href="#logging_with_api">Logging With API</a></li>
<li><a href="#privacy">Protecting User Privacy</a></li>
</ul>

<a name="dependencies"/>

## Dependencies

Requires Ruby 2.x. No other dependencies to conflict with your app.

<a name="installing_with_bundler"/>

## Installing With Bundler

Add this line to your Gemfile:

```
gem 'resurfaceio-logger'
```

Then install with Bundler: `bundle install`

<a name="logging_from_rails_controller"/>

## Logging From Rails Controller

After <a href="#installing_with_bundler">installing the gem</a>, add an `around_action` to your Rails controller.

```ruby
require 'resurfaceio/all'

class MyController < ApplicationController
  
  around_action HttpLoggerForRails.new(
    url: 'https://...', 
    rules: 'include strict'
  )

end
```

<a name="logging_from_rack_middleware"/>

## Logging From Rack Middleware

After <a href="#installing_with_bundler">installing the gem</a>, add these lines below to `config.ru`, before the final
'run' statement.

```ruby
require 'resurfaceio/all'

use HttpLoggerForRack,
  url: 'https://...',
  rules: 'include strict'

run <...>
```

<a name="logging_from_sinatra"/>

## Logging From Sinatra

After <a href="#installing_with_bundler">installing the gem</a>, create a logger and call it from the routes of interest.

```ruby
require 'sinatra'
require 'resurfaceio/all'

logger = HttpLogger.new(
  url: 'https://...', 
  rules: 'include strict'
)

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

<a name="logging_with_api"/>

## Logging With API

Loggers can be directly integrated into your application using our [API](API.md). This requires the most effort compared with
the options described above, but also offers the greatest flexibility and control.

[API documentation](API.md)

<a name="privacy"/>

## Protecting User Privacy

Loggers always have an active set of <a href="https://resurface.io/rules.html">rules</a> that control what data is logged
and how sensitive data is masked. All of the examples above apply a predefined set of rules (`include strict`),
but logging rules are easily customized to meet the needs of any application.

<a href="https://resurface.io/rules.html">Logging rules documentation</a>

---
<small>&copy; 2016-2019 <a href="https://resurface.io">Resurface Labs Inc.</a></small>
