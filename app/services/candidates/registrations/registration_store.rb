# Reads and writes registraion sessions to the cache under a random key
module Candidates
  module Registrations
    class RegistrationStore
      class SessionNotFound < StandardError; end
      TTL = 1.day
      NAMESPACE = 'pending_confirmations'.freeze

      def self.store(registration_session)
        uuid = SecureRandom.urlsafe_base64
        Rails.cache.write \
          uuid,
          registration_session.to_h,
          expires_in: TTL,
          namespace: NAMESPACE

        uuid
      end

      def self.find_by!(uuid: uuid)
        hash = Rails.cache.read uuid, namespace: NAMESPACE
        raise SessionNotFound unless hash
        Rails.cache.delete uuid
        RegistrationSession.new hash
      end
    end
  end
end
