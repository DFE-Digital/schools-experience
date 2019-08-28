module Bookings
  module Gitis
    class Contact
      include Entity

      entity_id_attribute :contactid

      entity_attributes :firstname, :lastname, :birthdate, except: :update

      entity_attributes :emailaddress1, :emailaddress2
      entity_attributes :address1_line1, :address1_line2, :address1_line3
      entity_attributes :address1_city, :address1_stateorprovince
      entity_attributes :address1_postalcode
      entity_attributes :telephone1, :address1_telephone1, :telephone2
      entity_attributes :dfe_hasdbscertificate, :dfe_dateofissueofdbscertificate
      entity_attributes :dfe_notesforclassroomexperience
      entity_attributes :mobilephone, :dfe_channelcreation, except: :update

      entity_association :ownerid, Team
      entity_association :dfe_Country, Country
      entity_association :dfe_PreferredTeachingSubject01, TeachingSubject
      entity_association :dfe_PreferredTeachingSubject02, TeachingSubject

      alias_attribute :first_name, :firstname
      alias_attribute :last_name, :lastname
      alias_attribute :building, :address1_line1
      alias_attribute :town_or_city, :address1_city
      alias_attribute :county, :address1_stateorprovince
      alias_attribute :postcode, :address1_postalcode

      validates :email, presence: true, format: /\A.+@.+\..+\z/

      def self.channel_creation
        Rails.application.config.x.gitis.channel_creation
      end

      def initialize(crm_contact_data = {})
        @crm_data                             = crm_contact_data.stringify_keys
        self.contactid                        = @crm_data['contactid']
        self.firstname                        = @crm_data['firstname']
        self.lastname                         = @crm_data['lastname']
        self.emailaddress1                    = @crm_data['emailaddress1']
        self.emailaddress2                    = @crm_data['emailaddress2']
        self.telephone1                       = @crm_data['telephone1']
        self.telephone2                       = @crm_data['telephone2']
        self.address1_line1                   = @crm_data['address1_line1']
        self.address1_line2                   = @crm_data['address1_line2']
        self.address1_line3                   = @crm_data['address1_line3']
        self.address1_city                    = @crm_data['address1_city']
        self.address1_stateorprovince         = @crm_data['address1_stateorprovince']
        self.address1_postalcode              = @crm_data['address1_postalcode']
        self.address1_telephone1              = @crm_data['address1_telephone1']
        self.birthdate                        = @crm_data['birthdate']
        self.dfe_channelcreation              = @crm_data['dfe_channelcreation'] || self.class.channel_creation
        self.dfe_hasdbscertificate            = @crm_data['dfe_hasdbscertificate']
        self.dfe_dateofissueofdbscertificate  = @crm_data['dfe_dateofissueofdbscertificate']
        self.dfe_notesforclassroomexperience  = @crm_data['dfe_notesforclassroomexperience']
        self.ownerid                          = @crm_data['_ownerid_value'] || Team.default
        self.dfe_Country                      = @crm_data['_dfe_countryid_value'] || Country.default
        self.dfe_PreferredTeachingSubject01   = @crm_data['_dfe_preferredteachingsubject01_value']
        self.dfe_PreferredTeachingSubject02   = @crm_data['_dfe_preferredteachingsubject02_value']

        super # handles resetting dirty attributes

        if @crm_data['emailaddress2'].blank? && @crm_data['emailaddress1'].present?
          self.emailaddress2 = @crm_data['emailaddress1']
        end

        if @crm_data['telephone2'].blank?
          self.telephone2 = @crm_data['mobilephone'].presence || \
            @crm_data['address1_telephone1'].presence || \
            @crm_data['telephone1'].presence || \
            self.telephone2
        end
      end

      def created_by_us?
        dfe_channelcreation.to_s == Rails.application.config.x.gitis.channel_creation.to_s
      end

      def address
        [building, street, town_or_city, county, postcode].compact.join(", ")
      end

      def email
        emailaddress2.presence || emailaddress1
      end

      def email=(emailaddress)
        if emailaddress1.blank? || created_by_us?
          self.emailaddress1 = emailaddress
        end

        self.emailaddress2 = emailaddress
      end

      def street=(line_2and3)
        self.address1_line2 = line_2and3
        self.address1_line3 = ""
      end

      def street
        [address1_line2, address1_line3].map(&:presence).compact.join(', ')
      end

      def full_name
        "#{firstname} #{lastname}"
      end

      def phone
        telephone2.presence || telephone1.presence || mobilephone
      end

      def phone=(phonenumber)
        if created_by_us? || telephone1.blank?
          self.telephone1 = phonenumber&.strip
        end

        if created_by_us? || address1_telephone1.blank?
          self.address1_telephone1 = phonenumber&.strip
        end

        self.telephone2 = phonenumber&.strip
      end

      def date_of_birth
        birthdate.present? ? Date.parse(birthdate) : nil
      end

      def date_of_birth=(dob)
        self.birthdate = dob.present? ? dob.to_formatted_s(:db) : nil
      end

      def has_dbs_check
        dfe_hasdbscertificate
      end

      def has_dbs_check=(value)
        if value != dfe_hasdbscertificate
          self.dfe_dateofissueofdbscertificate = nil
        end

        self.dfe_hasdbscertificate = value
      end

      def signin_attributes_match?(fname, lname, dob)
        gitis_format_dob = dob.to_formatted_s(:db)
        fname = fname.downcase
        lname = lname.downcase

        firstname.downcase == fname && lastname.downcase == lname ||
          firstname.downcase == fname && birthdate == gitis_format_dob ||
          lastname.downcase == lname && birthdate == gitis_format_dob
      end

      def add_school_experience(log_line)
        unless dfe_notesforclassroomexperience.present?
          self.dfe_notesforclassroomexperience = EventLogger::NOTES_HEADER + "\n\n"
        end

        self.dfe_notesforclassroomexperience = "#{dfe_notesforclassroomexperience}#{log_line}\n"
      end
    end
  end
end
