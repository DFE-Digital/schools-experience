module Candidates
  module Registrations
    module Behaviours
      module SubjectAndDateInformation
        extend ActiveSupport::Concern

        included do
          validates :bookings_placement_date_id,
            presence: true,
            if: :school_offers_fixed_dates?

          validates :bookings_placement_dates_subject_id,
            presence: true,
            if: :check_placement_date_validity?
        end

      private

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
