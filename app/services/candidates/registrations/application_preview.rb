module Candidates
  module Registrations
    class ApplicationPreview
      attr_reader \
        :account_check,
        :address,
        :placement_preference,
        :subject_preference,
        :background_check

      def initialize(account_check:, placement_preference:, address:, subject_preference:, background_check:)
        @account_check = account_check
        @placement_preference = placement_preference
        @address = address
        @subject_preference = subject_preference
        @background_check = background_check
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
        date_in_words(placement_preference.date_start) + ' to ' +
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
