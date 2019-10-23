module Bookings
  module Gitis
    module Store
      class Fake
        KNOWN_UUID = "b8dd28e3-7bed-4cc2-9602-f6ee725344d2".freeze
        REQUIRED = %w{
          firstname lastname emailaddress2 telephone2 birthdate
          address1_line1 address1_city address1_stateorprovince address1_postalcode
          dfe_channelcreation dfe_hasdbscertificate
          dfe_Country@odata.bind
        }.freeze
        ALLOWED = (
          REQUIRED + %w{
            telephone1 address1_telephone1 address1_line2 address1_line3
            emailaddress1 dfe_dateofissueofdbscertificate
            dfe_PreferredTeachingSubject01@odata.bind
            dfe_PreferredTeachingSubject02@odata.bind
          }
        ).freeze

        def initialize(*_args); end

        def create_entity(entity_id, data)
          return "#{entity_id}(#{fake_contact_id})" unless entity_id == 'contacts'

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
          return entity_id unless entity_id.start_with?('contacts(')

          data.keys.each do |key|
            unless ALLOWED.include?(key)
              raise "Bad Response - attribute '#{key}' is not recognised"
            end
          end

          entity_id
        end

        # only Contacts are mocked for now
        def find_one(_entity_type, uuid, _params)
          Contact.new(fake_contact_data.merge('contactid' => uuid))
        end

        # only Contacts are mocked for now
        def find_many(entity_type, uuids, params)
          uuids.map do |uuid|
            find_one(entity_type, uuid, params)
          end
        end

        def fetch(_entity_type, _filter: nil, limit: 10, _order: nil)
          (1..limit).map do |_index|
            Contact.new \
              fake_contact_data.merge('contactid' => SecureRandom.uuid)
          end
        end

      private

        def fake_contact_id
          fake_uuid = Rails.application.config.x.gitis.fake_crm_uuid

          if %w{true yes 1}.include? fake_uuid
            KNOWN_UUID
          else
            fake_uuid.presence || SecureRandom.uuid
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
            'address1_postalcode' => 'TE57 1NG',
            'address1_telephone1' => '01234 567890',
            'birthdate' => '1980-01-01',
            'dfe_channelcreation' => 10
          }
        end
      end
    end
  end
end
