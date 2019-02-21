# Reads and writes registraion sessions to redis under a random key
module Candidates
  module Registrations
    class RegistrationStore
      include Singleton

      class SessionNotFound < StandardError; end

      def initialize
        @namespace = 'registrations'.freeze
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

      def has_registration?(uuid)
        @redis.exists namespace(uuid)
      end

    private

      def delete(uuid)
        @redis.del namespace(uuid)
      end

      def namespace(key)
        "#{Rails.env}:#{@namespace}:#{key}"
      end

      def serialize(session)
        session.to_json
      end

      def deserialize(value)
        RegistrationSession.new JSON.parse(value)
      end
    end
  end
end
