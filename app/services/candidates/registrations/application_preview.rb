module Candidates
  module Registrations
    class ApplicationPreview
      # FIXME delegate other methods to placement_preference once remove dates
      # pr is merged
      attr_reader :placement_preference

      delegate \
        :full_name,
        :email,
        :phone,
        :building,
        :street,
        :town_or_city,
        :county,
        :postcode,
        to: :@contact_information

      delegate \
        :school_name,
        :degree_stage,
        :degree_subject,
        :teaching_stage,
        :subject_first_choice,
        :subject_second_choice,
        to: :@subject_preference

      delegate :has_dbs_check, to: :@background_check

      def initialize(registration_session)
        @contact_information = registration_session.contact_information
        @placement_preference = registration_session.placement_preference
        @subject_preference = registration_session.subject_preference
        @background_check = registration_session.background_check
      end

      def full_address
        [
          building,
          street,
          town_or_city,
          county,
          postcode
        ].compact.join(', ')
      end

      def telephone_number
        phone
      end

      def email_address
        email
      end

      def school
        school_name
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

      def teaching_subject_first_choice
        subject_first_choice
      end

      def teaching_subject_second_choice
        subject_second_choice
      end

      def dbs_check_document
        if has_dbs_check
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
