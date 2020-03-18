module Bookings::Gitis
  class FakeCrm < CRM
    NAMESPACE = 'fake-gitis'.freeze
    VERSION = 'v1'.freeze
    TTL = 3.minutes.freeze

    def initialize
      @store = fake_write_only_cache_store
    end

    def find_contact_for_signin(email:, firstname:, lastname:, date_of_birth:)
      return nil if email =~ /unknown/

      Contact.new(fake_contact_data).tap do |contact|
        contact.email = email
        contact.firstname = firstname
        contact.lastname = lastname
        contact.date_of_birth = date_of_birth
      end
    end

    def fake_store
      @fake_store ||= Store::Fake.new
    end

    def fake_contact_data
      fake_store.send :fake_contact_data
    end

  private

    def fake_write_only_cache_store
      Bookings::Gitis::Store::WriteOnlyCache.new fake_store, Rails.cache,
        namespace: NAMESPACE, ttl: TTL, version: VERSION
    end
  end
end
