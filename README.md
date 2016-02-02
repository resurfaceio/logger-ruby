# resurfaceio-logger-ruby
&copy; 2016 Resurface Labs LLC, All Rights Reserved

## Basic Workflow 

    git clone git@github.com:resurfaceio/resurfaceio-logger-ruby.git ~/resurfaceio-logger-ruby
    cd ~/resurfaceio-logger-ruby
    git pull
    (make changes)
    bundle exec rspec                         (run automated tests)
    git status                                (review changes)
    git add -A
    git commit -m "#123 Updated readme"       (123 is the GitHub issue number)
    git pull
    git push origin master

## Building Gem

    gem build resurfaceio-logger.gemspec

## Using Gem from GitHub

    gem 'resurfaceio-logger', :git => 'https://github.com/resurfaceio/resurfaceio-logger-ruby.git'
