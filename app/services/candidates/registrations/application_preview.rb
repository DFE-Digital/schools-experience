module Candidates
  module Registrations
    class ApplicationPreview
      # FIXME delegate other methods to placement_preference once remove dates
      # pr is merged
      attr_reader :placement_preference
      attr_reader :subject_and_date_information

      attr_reader :registration_session

      delegate \
        :first_name,
        :last_name,
        :full_name,
        :email,
        :read_only,
        to: :@personal_information

      delegate \
        :phone,
        :building,
        :street,
        :town_or_city,
        :county,
        :postcode,
        to: :@contact_information

      delegate \
        :degree_stage,
        :degree_subject,
        :description,
        to: :@education

      delegate \
        :teaching_stage,
        :subject_first_choice,
        :subject_second_choice,
        to: :@teaching_preference

      delegate \
        :placement_date,
        :placement_date_subject,
        to: :@subject_and_date_information

      delegate :has_dbs_check, to: :@background_check

      delegate :school, to: :@registration_session

      def initialize(registration_session)
        @registration_session = registration_session
        @personal_information = registration_session.personal_information
        @contact_information = registration_session.contact_information
        @placement_preference = registration_session.placement_preference
        @background_check = registration_session.background_check
        @education = registration_session.education
        @teaching_preference = registration_session.teaching_preference
        @subject_and_date_information = if registration_session.school.availability_preference_fixed?
                                          registration_session.subject_and_date_information
                                        else
                                          false
                                        end
      end

      def ==(other)
        other.is_a?(self.class) && \
          other.registration_session == @registration_session
      end

      def school_name
        school.name
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

      def date_of_birth
        @personal_information.date_of_birth&.strftime '%d/%m/%Y'
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

      def has_subject_and_date_information?
        !!@subject_and_date_information
      end

      def placement_date
        subject_and_date_information.placement_date.to_s
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

      def placement_request_url
        schools_placement_request_url(123)
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
