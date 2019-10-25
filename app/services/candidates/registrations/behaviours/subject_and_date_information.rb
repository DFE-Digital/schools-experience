module Candidates
  module Registrations
    module Behaviours
      module SubjectAndDateInformation
        extend ActiveSupport::Concern

        included do
          validates :bookings_placement_date_id,
            presence: true,
            if: :school_offers_fixed_dates?,
            unless: :dont_validate_availability?

          validates :bookings_placement_dates_subject_id,
            presence: true,
            if: :check_placement_date_validity?,
            unless: :dont_validate_placement_date_subject?

          validates :bookings_placement_date_id,
            presence: true,
            if: :check_placement_date_validity?,
            unless: :dont_validate_placement_date_subject?
        end

      private

        def dont_validate_availability?
          validation_context == :creating_placement_request_from_registration_session
        end

        def dont_validate_placement_date_subject?
          validation_context == :creating_placement_request_from_registration_session
        end

        def school_offers_fixed_dates?
          school.present? && school.availability_preference_fixed?
        end

        def check_placement_date_validity?
          bookings_placement_date_id.present? && placement_date&.subject_specific?
        end
      end
    end
  end
end
