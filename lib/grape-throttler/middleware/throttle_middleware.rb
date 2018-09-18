# frozen_string_literal: true

module GrapeThrottler
  module Middleware
    class ThrottleMiddleware < Grape::Middleware::Base

      COUNTER_START ||= 0

      def before
        endpoint = env['api.endpoint']
        logger = options[:logger] || Logger.new(STDOUT)

        return unless throttle_options = endpoint.route_setting(:throttle)

        limit, period = find_limit_and_period(throttle_options)

        check_limit_and_period(limit, period)

        limit = limit.call(env) if limit.is_a?(Proc)
        return true if limit.negative?

        user_value = find_user_value(options) || "ip:#{env['REMOTE_ADDR']}"
        rate_key = generate_rate_key(endpoint, user_value)

        begin
          redis = options[:cache]
          redis.ping

          current = redis.get(rate_key).to_i

          if !current.nil? && current >= limit
            endpoint.error!('Too Many Requests', 429)
          else
            redis.multi do
              redis.set(rate_key, COUNTER_START, { nx: true, ex: period.to_i })
              redis.incr(rate_key)
            end
          end
        rescue Exception => e
          logger.warn(e.message)
        end
      end

      private

      def check_limit_and_period(limit, period)
        return unless limit.nil? || period.nil?

        raise ArgumentError, 'Please set a period and limit (see documentation)'
      end

      def find_limit_and_period(throttle_options)
        if limit = throttle_options[:hourly]
          period = 1.hour
        elsif limit = throttle_options[:daily]
          period = 1.day
        elsif limit = throttle_options[:monthly]
          period = 1.month
        elsif period = throttle_options[:period]
          limit = throttle_options[:limit]
        end

        [limit, period]
      end

      def find_user_value(options)
        user_key = options[:user_key]
        return if user_key.nil?

        user_key.call(env)
      end

      def generate_rate_key(endpoint, user_value)
        epoint = endpoint.routes.first
        "#{epoint.request_method}:#{epoint.path}:#{user_value}"
      end

    end
  end
end
