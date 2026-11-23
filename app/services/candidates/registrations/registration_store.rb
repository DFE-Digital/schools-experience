# Reads and writes unfinished registrations to the candidate_registrations
# table, keyed by the registration's UUID.
#
# TRANSITION: registrations created before the move to the database still live
# in Redis (one day TTL). Reads that miss the database fall back to Redis and
# move the record across; deletes remove both copies. Writes never touch Redis,
# so a database record always supersedes a legacy one. Remove the legacy_*
# methods once a day has passed since deploying.
module Candidates
  module Registrations
    class RegistrationStore
      include Singleton

      class SessionNotFound < StandardError; end

      class NoKey < StandardError; end

      def initialize
        @ttl = 1.day.to_i
      end

      def store!(registration_session)
        key = registration_session.uuid

        if key.blank?
          raise NoKey, "`registration_session#uuid` can't be blank"
        end

        CandidateRegistration.upsert(
          {
            uuid: key,
            registration_data: serialize(registration_session),
            expires_at: @ttl.seconds.from_now
          },
          unique_by: :uuid
        )
      end

      def retrieve!(uuid)
        value = live_registrations.find_by(uuid: uuid)&.registration_data
        value ||= migrate_legacy_registration(uuid)
        raise SessionNotFound unless value

        deserialize(value)
      end

      # If we're trying to delete keys that no longer exist we're probably
      # doing something wrong and should find out!
      def delete!(uuid)
        deleted = live_registrations.where(uuid: uuid).delete_all
        deleted += legacy_redis.del(legacy_key(uuid)) unless uuid.nil?
        raise SessionNotFound if deleted.zero?

        true
      end

      def has_registration?(uuid)
        live_registrations.exists?(uuid: uuid) ||
          legacy_redis.exists?(legacy_key(uuid))
      end

    private

      def live_registrations
        CandidateRegistration.live
      end

      def serialize(session)
        session.to_json
      end

      def deserialize(value)
        RegistrationSession.new JSON.parse(value)
      end

      def legacy_redis
        REDIS
      end

      def legacy_key(uuid)
        "#{Rails.env}:registrations:#{uuid}"
      end

      # Copies a Redis registration into the database, keeping its remaining
      # lifetime, then removes the Redis copy. The insert never overwrites an
      # existing row, so a newer database record always wins.
      def migrate_legacy_registration(uuid)
        key = legacy_key(uuid)
        value = legacy_redis.get(key)
        return unless value

        remaining = legacy_redis.ttl(key)
        return if remaining == -2

        remaining = @ttl if remaining.negative?

        CandidateRegistration.insert(
          {
            uuid: uuid,
            registration_data: value,
            expires_at: remaining.seconds.from_now
          },
          unique_by: :uuid
        )
        legacy_redis.del(key)

        live_registrations.find_by(uuid: uuid)&.registration_data
      end
    end
  end
end
