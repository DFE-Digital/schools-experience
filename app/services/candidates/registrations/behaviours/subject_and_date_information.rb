module Candidates
  module Registrations
    module Behaviours
      module SubjectAndDateInformation
        extend ActiveSupport::Concern

        included do
          validates :bookings_placement_date_id,
            presence: true,
            if: :school_offers_fixed_dates?,
            unless: :creating_placement_request_from_registration_session?
        end

      private

        def creating_placement_request_from_registration_session?
          validation_context == :creating_placement_request_from_registration_session
        end

        def school_offers_fixed_dates?
          school.present? && school.availability_preference_fixed?
        end

        def for_subject_specific_date?
          bookings_placement_date_id.present? && placement_date&.subject_specific?
        end
      end
    end
  end
end
