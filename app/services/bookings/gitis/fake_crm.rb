module Bookings::Gitis
  class FakeCrm < CRM
    def initialize
      @store = Store::Fake.new
    end

    def find_contact_for_signin(email:, firstname:, lastname:, date_of_birth:)
      return super unless store.is_a?(Store::Fake)
      return nil if email =~ /unknown/

      Contact.new(store.send(:fake_contact_data)).tap do |contact|
        contact.email = email
      end
    end
  end
end
