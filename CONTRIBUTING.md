# Contributing to resurfaceio-logger-ruby
&copy; 2016-2019 Resurface Labs Inc.

## Coding Conventions

Our code style is whatever RubyMine does by default, with the exception of allowing lines up to 130 characters.
If you don't use RubyMine, that's ok, but your code may get reformatted.

## Git Workflow

Initial setup:

```
git clone git@github.com:resurfaceio/logger-ruby.git resurfaceio-logger-ruby
cd resurfaceio-logger-ruby
bundle install
```

Running unit tests:

```
bundle exec rspec
```

Committing changes:

```
git add -A
git commit -m "#123 Updated readme"       (123 is the GitHub issue number)
git pull --rebase                         (avoid merge bubbles)
git push origin master
```

## Release Process

All [integration tests](https://github.com/resurfaceio/logger-tests) must pass first.

Push artifacts to [RubyGems.org](https://rubygems.org/):

```
gem build resurfaceio-logger.gemspec
gem push <gemfile>
```

Tag release version:

```
git tag v1.x.x
git push origin master --tags
```

Start the next version by incrementing the version number.
