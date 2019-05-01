module Candidates
  module Registrations
    module Behaviours
      module PlacementPreference
        extend ActiveSupport::Concern

        included do
          validates :urn, presence: true
          validates :bookings_placement_date_id,
            presence: true,
            if: -> { urn.present? && school_offers_fixed_dates? }
          validates :availability,
            presence: true,
            unless: -> { urn.present? && school_offers_fixed_dates? }
          validates :availability, number_of_words: { less_than: 150 }, if: -> { availability.present? }
          validates :objectives, presence: true
          validates :objectives, number_of_words: { less_than: 150 }, if: -> { objectives.present? }
        end

      private

        def school_offers_fixed_dates?
          school.availability_preference_fixed?
        end
      end
    end
  end
end
