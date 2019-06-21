module Bookings::Gitis
  module FakeCrm
    KNOWN_UUID = "b8dd28e3-7bed-4cc2-9602-f6ee725344d2".freeze

    def find_by_email(address)
      return super unless stubbed?
      return nil if address =~ /unknown/

      Contact.new(fake_contact_data).tap do |contact|
        contact.email = address
      end
    end

  private

    def create_entity(entity_id, _data)
      return super unless stubbed?

      "#{entity_id}(#{fake_contact_id})"
    end

    def update_entity(entity_id, _data)
      return super unless stubbed?

      entity_id
    end

    def fake_contact_id
      if Rails.env.test? || Rails.env.servertest?
        SecureRandom.uuid # Mock it if predictable behaviour required
      elsif %w{true yes 1}.include? ENV['FAKE_CRM_UUID'].to_s
        KNOWN_UUID
      elsif ENV['FAKE_CRM_UUID'].present?
        ENV['FAKE_CRM_UUID']
      else
        SecureRandom.uuid
      end
    end

    def fake_contact_data
      {
        'contactid' => fake_contact_id,
        'firstname' => 'Matthew',
        'lastname' => 'Richards',
        'mobilephone' => '07123 456789',
        'telephone1' => '01234 567890',
        'emailaddress1' => 'first@thisaddress.com',
        'emailaddress2' => 'second@thisaddress.com',
        'emailaddress3' => 'third@thisaddress.com',
        'address1_line1' => 'First Line',
        'address1_line2' => 'Second Line',
        'address1_line3' => 'Third Line',
        'address1_city' => 'Manchester',
        'address1_stateorprovince' => 'Manchester',
        'address1_postalcode' => 'MA1 1AM'
      }
    end

    def stubbed?
      Rails.application.config.x.fake_crm
    end

    # only Contacts are mocked for now
    def find_one(_entity_type, uuid, params)
      return super unless stubbed?

      Contact.new(fake_contact_data.merge('contactid' => uuid))
    end

    # only Contacts are mocked for now
    def find_many(entity_type, uuids, params)
      return super unless stubbed?

      uuids.map do |uuid|
        find_one(entity_type, uuid, params)
      end
    end
  end
end
