module Candidates
  module Registrations
    class ApplicationPreview
      attr_reader \
        :account_check,
        :address,
        :placement_preference,
        :subject_preference,
        :background_check

      def initialize(registration)
        @account_check = AccountCheck.new registration.fetch(AccountCheck.model_name.param_key)
        @placement_preference = PlacementPreference.new registration.fetch(PlacementPreference.model_name.param_key)
        @address = Address.new registration.fetch(Address.model_name.param_key)
        @subject_preference = SubjectPreference.new registration.fetch(SubjectPreference.model_name.param_key)
        @background_check = BackgroundCheck.new registration.fetch(BackgroundCheck.model_name.param_key)
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
        ].join(', ')
      end

      def telephone_number
        address.phone
      end

      def email_address
        account_check.email
      end

      def school
        'SCHOOL_STUB'
      end

      def placement_availability
        placement_preference.date_start.strftime('%d %B %Y') + ' to ' +
          placement_preference.date_end.strftime('%d %B %Y')
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
    end
  end
end
