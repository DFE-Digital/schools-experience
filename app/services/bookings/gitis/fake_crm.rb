module Bookings::Gitis
  module FakeCrm
    def find(ids)
      return super unless stubbed?

      multiple_ids = ids.is_a? Array
      ids = normalise_ids(ids)
      validate_ids(ids)

      if multiple_ids
        ids.map do |id|
          Contact.new(fake_contact_data.merge('contactid' => id))
        end
      else
        Contact.new(fake_contact_data.merge('contactid' => ids[0]))
      end
    end

    def find_by_email(address)
      return super unless stubbed?

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
      SecureRandom.uuid
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
  end
end
