# Reads and writes registraion sessions to the cache under a random key
module Candidates
  module Registrations
    class RegistrationStore
      class SessionNotFound < StandardError; end
      TTL = 1.day

      def self.namespace
        'pending_confirmations'.freeze
      end

      def self.store(registration_session)
        uuid = SecureRandom.urlsafe_base64
        Rails.cache.write \
          uuid,
          registration_session.to_h,
          expires_in: TTL,
          namespace: namespace

        uuid
      end

      def self.find_by!(uuid:)
        hash = Rails.cache.read uuid, namespace: namespace
        raise SessionNotFound unless hash

        RegistrationSession.new hash
      end

      def self.remove!(uuid:)
        Rails.cache.delete uuid
      end
    end
  end
end
