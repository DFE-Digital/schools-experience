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
        :school,
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
          building.presence,
          street.presence,
          town_or_city.presence,
          county.presence,
          postcode.presence
        ].compact.join(', ')
      end

      def has_bookings_date?
        @placement_preference.bookings_placement_date_id.present?
      end

      def telephone_number
        phone
      end

      def email_address
        email
      end

      def placement_date
        placement_preference.placement_date
      end

      def placement_availability
        placement_preference.availability
      end

      def placement_availability_description
        placement_preference.availability || placement_preference.placement_date.to_s
      end

      def placement_outcome
        placement_preference.objectives
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
    end
  end
end
