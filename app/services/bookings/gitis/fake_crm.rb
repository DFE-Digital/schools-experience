module Bookings::Gitis
  module FakeCrm
    KNOWN_UUID = "b8dd28e3-7bed-4cc2-9602-f6ee725344d2".freeze
    REQUIRED = %w{
      firstname lastname emailaddress2 telephone2 birthdate
      address1_line1 address1_city address1_stateorprovince address1_postalcode
      statecode dfe_channelcreation
    }.freeze
    ALLOWED = (
      REQUIRED + %w{telephone1 address1_line2 address1_line3 emailaddress1}
    ).freeze

    def find_by_email(address)
      return super unless stubbed?
      return nil if address =~ /unknown/

      Contact.new(fake_contact_data).tap do |contact|
        contact.email = address
      end
    end

    def find_contact_for_signin(email:, firstname:, lastname:, date_of_birth:)
      return super unless stubbed?
      return nil if email =~ /unknown/

      Contact.new(fake_contact_data).tap do |contact|
        contact.email = email
      end
    end

  private

    def create_entity(entity_id, data)
      return super unless stubbed?

      REQUIRED.each do |key|
        unless data.has_key?(key)
          raise "Bad Response - attribute '#{key}' is missing"
        end
      end

      data.keys.each do |key|
        unless ALLOWED.include?(key)
          raise "Bad Response - attribute '#{key}' is not recognised"
        end
      end

      "#{entity_id}(#{fake_contact_id})"
    end

    def update_entity(entity_id, data)
      return super unless stubbed?

      data.keys.each do |key|
        unless ALLOWED.include?(key)
          raise "Bad Response - attribute '#{key}' is not recognised"
        end
      end

      entity_id
    end

    def fake_contact_id
      if %w{true yes 1}.include? config.fake_crm_uuid.to_s
        KNOWN_UUID
      else
        config.fake_crm_uuid.presence || SecureRandom.uuid
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
        'address1_postalcode' => 'MA1 1AM',
        'birthdate' => '1980-01-01',
        'statecode' => 0,
        'dfe_channelcreation' => 10
      }
    end

    def stubbed?
      Rails.application.config.x.gitis.fake_crm
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
