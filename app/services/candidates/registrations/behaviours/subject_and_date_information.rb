module Candidates
  module Registrations
    module Behaviours
      module SubjectAndDateInformation
        extend ActiveSupport::Concern

        included do
          validates :bookings_placement_date_id,
            presence: true
          validates :subject_id, presence: true
        end

      private

        def school_offers_fixed_dates?
          school.present? && school.availability_preference_fixed?
        end
      end
    end
  end
end
