module Bookings
  module Gitis
    class Contact
      include Entity

      def self.channel_creation
        Rails.application.config.x.gitis.channel_creation
      end

      entity_id_attribute :contactid

      entity_attributes :firstname, :lastname, :birthdate, except: :update

      entity_attributes :emailaddress1, :emailaddress2
      entity_attributes :address1_line1, :address1_line2, :address1_line3
      entity_attributes :address1_city, :address1_stateorprovince
      entity_attributes :address1_postalcode
      entity_attributes :telephone1, :address1_telephone1, :telephone2
      entity_attributes :dfe_hasdbscertificate, :dfe_dateofissueofdbscertificate
      entity_attributes :dfe_notesforclassroomexperience
      entity_attributes :mobilephone, except: :update
      entity_attribute  :dfe_channelcreation, except: :update, default: channel_creation

      entity_association :dfe_Country, Country, default: Country.default
      entity_association :dfe_PreferredTeachingSubject01, TeachingSubject
      entity_association :dfe_PreferredTeachingSubject02, TeachingSubject

      entity_collection :dfe_contact_dfe_candidateprivacypolicy_Candidate, CandidatePrivacyPolicy

      alias_attribute :first_name, :firstname
      alias_attribute :last_name, :lastname
      alias_attribute :building, :address1_line1
      alias_attribute :town_or_city, :address1_city
      alias_attribute :county, :address1_stateorprovince
      alias_attribute :postcode, :address1_postalcode

      validates :email, presence: true, format: /\A.+@.+\..+\z/
      validates :'dfe_Country@odata.bind', presence: true, format: BIND_FORMAT, allow_nil: true
      validates :'dfe_PreferredTeachingSubject01@odata.bind', presence: true, format: BIND_FORMAT, allow_nil: true
      validates :'dfe_PreferredTeachingSubject02@odata.bind', presence: true, format: BIND_FORMAT, allow_nil: true

      def initialize(crm_contact_data = {})
        super # handles populating

        set_email_address_2_if_blank
        set_telephone_2_if_blank @init_data
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
          self.dfe_notesforclassroomexperience = EventLogger::NOTES_HEADER + "\r\n\r\n"
        end

        self.dfe_notesforclassroomexperience = "#{dfe_notesforclassroomexperience}#{log_line}\r\n"
      end

    private

      def set_email_address_2_if_blank
        return if emailaddress2.present? || emailaddress1.blank?

        self.emailaddress2 = emailaddress1
      end

      def set_telephone_2_if_blank(data = {})
        return if telephone2.present?

        self.telephone2 = data['mobilephone'].presence || \
          data['address1_telephone1'].presence || \
          data['telephone1'].presence || \
          telephone2
      end
    end
  end
end
