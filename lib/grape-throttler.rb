# frozen_string_literal: true

require 'grape' unless defined?(Grape)
require 'logger' unless defined?(Logger)

require 'grape-throttler/version'

require 'grape-throttler/extensions/throttle_extension'

module GrapeThrottler
  module Middleware

    autoload :ThrottleMiddleware, 'grape-throttler/middleware/throttle_middleware'

  end
end
