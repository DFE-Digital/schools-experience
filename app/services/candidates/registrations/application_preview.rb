module Candidates
  module Registrations
    class ApplicationPreview
      attr_reader \
        :contact_information,
        :placement_preference,
        :subject_preference,
        :background_check

      def initialize(registration_session)
        @contact_information = registration_session.contact_information
        @placement_preference = registration_session.placement_preference
        @subject_preference = registration_session.subject_preference
        @background_check = registration_session.background_check
      end

      def full_name
        contact_information.full_name
      end

      def full_address
        [
          contact_information.building,
          contact_information.street,
          contact_information.town_or_city,
          contact_information.county,
          contact_information.postcode
        ].compact.join(', ')
      end

      def telephone_number
        contact_information.phone
      end

      def email_address
        contact_information.email
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
