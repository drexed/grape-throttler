# frozen_string_literal: true

module GrapeThrottler
  module Middleware
    class ThrottleMiddleware < Grape::Middleware::Base

      COUNTER_START = 0

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      # rubocop:disable Metrics/PerceivedComplexity, Lint/AssignmentInCondition
      def before
        endpoint = env['api.endpoint']
        logger = options[:logger] || Logger.new($stdout)

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
              redis.set(rate_key, COUNTER_START, nx: true, ex: period.to_i)
              redis.incr(rate_key)
            end
          end
        rescue StandardError => e
          logger.warn(e.message)
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity, Lint/AssignmentInCondition
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength

      private

      def check_limit_and_period(limit, period)
        return unless limit.nil? || period.nil?

        raise ArgumentError, 'Please set a period and limit (see documentation)'
      end

      # rubocop:disable Lint/AssignmentInCondition
      def find_limit_and_period(throttle_options)
        if limit = throttle_options[:hourly]
          period = 3_600
        elsif limit = throttle_options[:daily]
          period = 86_400
        elsif limit = throttle_options[:monthly]
          period = 2_629_746
        elsif period = throttle_options[:period]
          limit = throttle_options[:limit]
        end

        [limit, period]
      end
      # rubocop:enable Lint/AssignmentInCondition

      def find_user_value(options)
        user_key = options[:user_key]
        return if user_key.nil?

        user_key.call(env)
      end

      def generate_rate_key(endpoint, user_value)
        endpoint_route = endpoint.routes.first
        "#{endpoint_route.request_method}:#{endpoint_route.path}:#{user_value}"
      end

    end
  end
end
