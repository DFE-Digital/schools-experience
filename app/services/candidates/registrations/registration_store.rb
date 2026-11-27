# Reads and writes unfinished registrations, keyed by the registration's UUID.
#
# Registrations live in the candidate_registrations table. While moving off
# Redis, SessionStorage.phase decides where they are read from and whether
# Redis is still written (see docs/documents/session-storage-cutover.md).
# Records are never copied between stores on read: every write and delete
# updates both stores together under one advisory lock, so a delete can't be
# undone by a concurrent copy and the stores never disagree about a deletion.
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

        value = serialize(registration_session)

        CandidateRegistration.with_advisory_lock(key) do
          CandidateRegistration.upsert(
            { uuid: key, registration_data: value, expires_at: @ttl.seconds.from_now },
            unique_by: :uuid
          )
          legacy_redis.set(legacy_key(key), value, ex: @ttl) if SessionStorage.redis_written?
        end
      end

      def retrieve!(uuid)
        value = read(uuid)
        raise SessionNotFound unless value

        deserialize(value)
      end

      # If we're trying to delete keys that no longer exist we're probably
      # doing something wrong and should find out!
      def delete!(uuid)
        deleted = CandidateRegistration.with_advisory_lock(uuid) do
          from_database = CandidateRegistration.live.where(uuid: uuid).delete_all
          from_redis = SessionStorage.redis_written? ? legacy_redis.del(legacy_key(uuid)) : 0
          SessionStorage.redis_authoritative? ? from_redis : from_database
        end
        raise SessionNotFound if deleted.zero?

        true
      end

      def has_registration?(uuid)
        if SessionStorage.redis_authoritative?
          legacy_redis.exists?(legacy_key(uuid))
        else
          CandidateRegistration.live.exists?(uuid: uuid)
        end
      end

    private

      def read(uuid)
        if SessionStorage.redis_authoritative?
          legacy_redis.get(legacy_key(uuid))
        else
          CandidateRegistration.live.find_by(uuid: uuid)&.registration_data
        end
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
    end
  end
end
