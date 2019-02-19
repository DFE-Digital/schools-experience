module Candidates
  module Registrations
    class ApplicationPreview
      attr_accessor \
        :account_check,
        :address,
        :placement_preference,
        :subject_preference,
        :background_check

      def initialize(registration_session)
        self.account_check = registration_session.account_check
        self.placement_preference = registration_session.placement_preference
        self.address = registration_session.address
        self.subject_preference = registration_session.subject_preference
        self.background_check = registration_session.background_check
      end

      def full_name
        account_check.full_name
      end

      def full_address
        [
          address.building,
          address.street,
          address.town_or_city,
          address.county,
          address.postcode
        ].compact.join(', ')
      end

      def telephone_number
        address.phone
      end

      def email_address
        account_check.email
      end

      def school
        subject_preference.school_name
      end

      def placement_availability
        "#{placement_date_start} to #{placement_date_end}"
      end

      def placement_date_start
        date_in_words(placement_preference.date_start)
      end

      def placement_date_end
        date_in_words(placement_preference.date_end)
      end

      def placement_outcome
        placement_preference.objectives
      end

      def access_needs
        if placement_preference.access_needs
          placement_preference.access_needs_details
        else
          'None'
        end
      end

      def degree_stage
        subject_preference.degree_stage
      end

      def degree_subject
        subject_preference.degree_subject
      end

      def teaching_stage
        subject_preference.teaching_stage
      end

      def teaching_subject_first_choice
        subject_preference.subject_first_choice
      end

      def teaching_subject_second_choice
        subject_preference.subject_second_choice
      end

      def dbs_check_document
        if background_check.has_dbs_check
          'Yes'
        else
          'No'
        end
      end

    private

      def date_in_words(date)
        date.strftime '%d %B %Y'
      end
    end
  end
end
