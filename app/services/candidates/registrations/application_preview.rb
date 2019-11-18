module Candidates
  module Registrations
    class ApplicationPreview
      class NotImplementedForThisDateType < StandardError; end
      # FIXME delegate other methods to placement_preference once remove dates
      # pr is merged
      attr_reader :placement_preference

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
        :degree_subject,
        to: :@education

      delegate \
        :teaching_stage,
        :subject_first_choice,
        :subject_second_choice,
        to: :@teaching_preference

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
      end

      def subject_and_date_information
        fail NotImplementedForThisDateType unless has_subject_and_date_information?

        @subject_and_date_information ||= @registration_session.subject_and_date_information
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
        RegistrationState.new(@registration_session).subject_and_date_information_in_journey?
      end

      def placement_date_subject
        fail NotImplementedForThisDateType unless has_subject_and_date_information?

        subject_and_date_information.placement_date_subject
      end

      def placement_date
        fail NotImplementedForThisDateType unless has_subject_and_date_information?

        subject_and_date_information.placement_date.to_s
      end

      def placement_availability
        fail NotImplementedForThisDateType if has_subject_and_date_information?

        placement_preference.availability
      end

      def placement_availability_description
        if has_subject_and_date_information?
          placement_date
        else
          placement_availability
        end
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

      def degree_stage
        [
          @education.degree_stage,
          @education.degree_stage_explaination
        ].map(&:presence).compact.join("\n")
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
