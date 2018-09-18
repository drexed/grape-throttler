# frozen_string_literal: true

%w[grape logger].each do |file_name|
  require file_name
end

%w[version extensions/throttle_extension].each do |file_name|
  require "grape-throttler/#{file_name}"
end

module GrapeThrottler
  module Middleware

    autoload :ThrottleMiddleware, 'grape-throttler/middleware/throttle_middleware'

  end
end
