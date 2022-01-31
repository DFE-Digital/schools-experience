module Candidates
  module Registrations
    class ApplicationPreview
      class NotImplementedForThisDateType < StandardError; end
      # FIXME: delegate other methods to placement_preference once remove dates
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
      delegate :availability, to: :@availability_preference

      def initialize(registration_session)
        @registration_session = registration_session
        @personal_information = registration_session.personal_information
        @contact_information = registration_session.contact_information
        @placement_preference = registration_session.placement_preference
        @availability_preference = registration_session.availability_preference unless has_subject_and_date_information?
        @background_check = registration_session.background_check
        @education = registration_session.education
        @teaching_preference = registration_session.teaching_preference
      end

      def subject_and_date_information
        raise NotImplementedForThisDateType unless has_subject_and_date_information?

        @subject_and_date_information ||= @registration_session.subject_and_date_information
      end

      def ==(other)
        other.is_a?(self.class) && \
          other.registration_session == @registration_session
      end

      delegate :name, to: :school, prefix: true

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

      def has_subject_and_date_information?
        RegistrationState.new(@registration_session).subject_and_date_information_in_journey?
      end

      def placement_date_subject
        raise NotImplementedForThisDateType unless has_subject_and_date_information?

        subject_and_date_information.placement_date_subject
      end

      def placement_date
        raise NotImplementedForThisDateType unless has_subject_and_date_information?

        subject_and_date_information.placement_date.to_s
      end

      def placement_availability
        raise NotImplementedForThisDateType if has_subject_and_date_information?

        availability
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
        ].map(&:presence).compact.join(" - ")
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
