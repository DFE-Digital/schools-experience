module Bookings
  module Gitis
    class Factory
      NAMESPACE = 'gitis'.freeze
      TTL = 1.hour.freeze

      class << self
        delegate :crm, :caching_crm, to: :new
        alias_method :gitis, :crm
      end

      def crm(read_from_cache: false)
        if Rails.application.config.x.gitis.fake_crm
          Bookings::Gitis::FakeCrm.new
        elsif Rails.application.config.x.gitis.caching
          Bookings::Gitis::CRM.new caching_store(read_from_cache)
        else
          Bookings::Gitis::CRM.new store
        end
      end

      def caching_crm
        crm read_from_cache: true
      end

      def token
        Bookings::Gitis::Auth.new.token
      end

      def store
        Bookings::Gitis::Store::Dynamics.new token
      end

      def write_only_caching_store
        Bookings::Gitis::Store::WriteOnlyCache.new \
          store, cache, namespace: NAMESPACE, ttl: TTL
      end

      def read_write_caching_store
        Bookings::Gitis::Store::ReadWriteCache.new \
          store, cache, namespace: NAMESPACE, ttl: TTL
      end

      def caching_store(read_from_cache = false)
        read_from_cache ? read_write_caching_store : write_only_caching_store
      end

    private

      def cache
        Rails.cache
      end
    end
  end
end
