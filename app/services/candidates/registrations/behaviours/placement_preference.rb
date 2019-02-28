module Candidates
  module Registrations
    module Behaviours
      module PlacementPreference
        extend ActiveSupport::Concern

        MAX_WORDS_FOR_AVAILABILITY = 149
        MAX_WORDS_FOR_OBJECTIVE = 149

        included do
          validates :availability, presence: true
          validate :availability_not_too_long, if: -> { availability.present? }
          validates :objectives, presence: true
          validate  :objectives_not_too_long, if: -> { objectives.present? }
        end

      private

        def availability_not_too_long
          if availability_too_long?
            errors.add :availability, :use_fewer_words
          end
        end

        def availability_too_long?
          availability.scan(/\s/).size > MAX_WORDS_FOR_AVAILABILITY
        end

        def objectives_not_too_long
          if objectives_too_long?
            errors.add :objectives, :use_fewer_words
          end
        end

        def objectives_too_long?
          objectives.scan(/\s/).size > MAX_WORDS_FOR_OBJECTIVE
        end
      end
    end
  end
end
