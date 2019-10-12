module Candidates
  module Registrations
    module Behaviours
      module SubjectAndDateInformation
        extend ActiveSupport::Concern

        included do
          validates :bookings_placement_date_id,
            presence: true,
            if: :school_offers_fixed_dates?
        end

      private

        def school_offers_fixed_dates?
          school.present? && school.availability_preference_fixed?
        end
      end
    end
  end
end
