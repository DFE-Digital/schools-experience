module Candidates
  module Registrations
    module Behaviours
      module PlacementPreference
        extend ActiveSupport::Concern

        included do
          with_options unless: :dont_validate_availability? do
            validates :availability,
              presence: true,
              if: :school_offers_flexible_dates?
          end
          validates :urn, presence: true
          validates :availability, number_of_words: { less_than: 150 }, if: -> { availability.present? }
          validates :objectives, presence: true
          validates :objectives, number_of_words: { less_than: 150 }, if: -> { objectives.present? }
        end

      private

        def dont_validate_availability?
          validation_context == :creating_placement_request_from_registration_session
        end

        def school_offers_fixed_dates?
          school.present? && school.availability_preference_fixed?
        end

        def school_offers_flexible_dates?
          !school_offers_fixed_dates?
        end
      end
    end
  end
end
