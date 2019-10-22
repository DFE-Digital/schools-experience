module Candidates
  module Registrations
    module Behaviours
      module PlacementPreference
        extend ActiveSupport::Concern

        included do
          with_options unless: :dont_validate_availability? do
            # The 'unless' clauses on the following validations ensure that if
            # placement requests are created when the school has fixed or flexible
            # dates selected *then toggles*, the PR won't be left in an invalid state
            #
            # At least either the availability or bookings_placement_date_id must
            # be present
            validates :bookings_placement_date_id,
              presence: true,
              if: :school_offers_fixed_dates?,
              unless: -> { availability.present? }
            validates :availability,
              presence: true,
              if: :school_offers_flexible_dates?,
              unless: -> { bookings_placement_date_id.present? }
          end
          validates :availability, number_of_words: { less_than: 150 }, if: -> { availability.present? }
          validates :objectives, presence: true
          validates :objectives, number_of_words: { less_than: 150 }, if: -> { objectives.present? }
        end

      private

        # If the school this placement request is for changes their availability
        # preference after the candidate completes the registration wizard but
        # before the candidate has completed the email confirmation step the
        # placement request could become invalid.
        def dont_validate_availability?
          validation_context == :returning_from_confirmation_email
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
