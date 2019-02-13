# Reads and writes registraion sessions to redis under a random key
module Candidates
  module Registrations
    class RegistrationStore
      include Singleton

      JSON_DATE = /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}/.freeze

      class SessionNotFound < StandardError; end

      def initialize
        @namespace = 'pending_confirmations'.freeze
        @ttl = 1.day.to_i
        @redis = Redis.current
      end

      def store!(registration_session)
        uuid = SecureRandom.urlsafe_base64
        @redis.set namespace(uuid), serialize(registration_session), ex: @ttl
        uuid
      end

      def retrieve!(uuid)
        value = @redis.get namespace(uuid)
        raise SessionNotFound unless value

        deserialize(value)
      end

      # If we're trying to delete keys that no longer exist we're probably
      # doing something wrong and should find out!
      def delete!(uuid)
        return_value = delete(uuid)
        raise SessionNotFound if return_value.zero?

        true
      end

    private

      def delete(uuid)
        @redis.del namespace(uuid)
      end

      def namespace(key)
        "#{@namespace}:#{key}"
      end

      def serialize(session)
        session.to_json
      end

      def deserialize(value)
        hash = JSON.parse(value)
        RegistrationSession.new deep_transform_json_dates(hash)
      end

      # GOVUK linter complains about Marshal so we need to do some work
      # ourselves to get date objects back when deserializing
      def deep_transform_json_dates(hash)
        hash.transform_values do |v|
          if v.is_a? Hash
            deep_transform_json_dates v
          else
            transform_json_dates v
          end
        end
      end

      def transform_json_dates(value)
        if is_a_json_date? value
          Time.zone.parse value
        else
          value
        end
      end

      def is_a_json_date?(value)
        value.is_a?(String) && JSON_DATE.match?(value)
      end
    end
  end
end
