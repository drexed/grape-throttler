# GrapeThrottler

[![Gem Version](https://badge.fury.io/rb/grape-throttler.svg)](http://badge.fury.io/rb/grape-throttler)
[![Build Status](https://travis-ci.org/drexed/grape-throttler.svg?branch=master)](https://travis-ci.org/drexed/grape-throttler)

GrapeThrottler provides a simple endpoint-specific throttling mechanism for Grape.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grape-throttler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grape-throttler

## Table of Contents

* [Configuration](#configuration)
* [Endpoint](#endpoint)

## Configuration
In your Grape API, install the middleware which will do the throttling. At a minimum, it requires a Redis instance for caching as the `cache` parameter.

**Simple Case**

```ruby
use GrapeThrottler::Middleware::ThrottleMiddleware, cache: Redis.new
```

In this simple case, you just set up the middleware, and pass it a Redis instance.

**Advanced Case**

```ruby
use GrapeThrottler::Middleware::ThrottleMiddleware, cache: $redis, user_key: ->(env) do
  # Use the current_user's id as an identifier
  user = current_user
  user.nil? ? nil : user.id
end
```

In this more advanced case, the Redis instance is in the global variable `$redis`.

The `user_key` parameter is a function that can be used to determine a custom identifier for a user. This key is used to form the Redis key to identify this user uniquely. It defaults to the IP address. The `env` parameter given to the function is the Rack environment and can be used to determine information about the caller.

**Logging**

The gem will log errors to STDOUT by default. If you prefer a different logger you can use the `logger` option to pass in your own logger.

```ruby
use GrapeThrottler::Middleware::ThrottleMiddleware, cache: Redis.new, logger: Logger.new('my_custom_log.log')
```

## Endpoint

This gem adds a `throttle` DSL-like method that can be used to throttle different endpoints differently.

The `throttle` method takes a Hash of the period to throttle, and the maximum allowed hits. After the maximum, the middleware throws an error with Grape's `error!` function.

Supported predefined periods are: `:hourly`, `:daily`, `:monthly`.

Example:

```ruby
class API < GrapeThrottler::API
  resources :users do

    # Allow start of competition only every 10 minutes
    desc 'Start competition'
    throttle period: 10.minutes, limit: 1
    params do
      requires :id, type: Integer, desc: 'id'
    end
    post '/:id/competition' do
      User.find(params[:id]).start_competition
    end

    # 3 times a day max
    desc 'Fetch a user'
    throttle daily: 3
    params do
      requires :id, type: Integer, desc: 'id'
    end
    get '/:id' do
      User.find(params[:id])
    end

    # Once a month or the user will go crazy
    desc 'Poke a user'
    throttle monthly: 1
    params do
      requires :id, type: Integer, desc: 'id'
    end
    post '/:id/poke' do
      User.find(params[:id]).poke
    end

    # No limit to the amount we can annoy users
    desc 'Annoy a user'
    params do
      requires :id, type: Integer, desc: 'id'
    end
    post '/:id/annoy' do
      User.find(params[:id]).annoy
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/grape-throttler. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Lite::Ruby project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/grape-throttler/blob/master/CODE_OF_CONDUCT.md).
