# resurfaceio-logger-ruby
&copy; 2016 Resurface Labs LLC, All Rights Reserved

## Installing with Bundler

Add this line to your Gemfile:

    gem 'resurfaceio-logger', :git => 'https://github.com/resurfaceio/resurfaceio-logger-ruby.git'

## Ruby API

    require 'resurfaceio/loggers'

    logger = HttpLoggerFactory.get       # returns default cached logger
    logger.disable                       # disable sending for automated tests
    logger.enable                        # enable sending for dev/staging/production
    logger.is_enabled?                   # intending to send messages?
    logger.log_request(request)          # log http request details
    logger.log_response(response)        # log http response details

## Using with Rails

### Logging HTTP requests and responses

    class WelcomeController < ApplicationController
      around_action HttpLoggerFilter.new
    end

### Logging just HTTP requests

    class WelcomeController < ApplicationController
      before_action HttpLoggerFilter.new
    end

### Logging just HTTP responses

    class WelcomeController < ApplicationController
      after_action HttpLoggerFilter.new
    end

### Custom around_action

    class WelcomeController < ApplicationController
      around_action :custom_around_action
      def custom_around_action
        logger = HttpLoggerFactory.get
        logger.log_request(request)
        begin
          yield
        ensure
          logger.log_response(response)
        end
      end
    end
