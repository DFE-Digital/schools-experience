module Candidates
  module Registrations
    module Behaviours
      module PlacementPreference
        extend ActiveSupport::Concern

        MAX_WORDS_FOR_OBJECTIVE = 50

        included do
          validates :date_start, presence: true
          validate  :date_start_is_a_date,
            if: -> { date_start.present? }
          validates :date_end, presence: true
          validate  :date_end_is_a_date,
            if: -> { date_end.present? }
          validate  :date_start_is_not_in_the_past,
            if: -> { date_start_is_a_date? }
          validate  :date_end_not_before_date_start,
            if: -> { date_start_is_a_date? && date_end_is_a_date? }
          validates :objectives, presence: true
          validate  :objectives_not_too_long, if: -> { objectives.present? }
        end

      private

        def date_start_is_a_date
          unless date_start_is_a_date?
            errors.add :date_start, :is_not_a_date
          end
        end

        def date_start_is_a_date?
          is_a_date? date_start
        end

        def date_end_is_a_date
          unless date_end_is_a_date?
            errors.add :date_end, :is_not_a_date
          end
        end

        def date_end_is_a_date?
          is_a_date? date_end
        end

        def is_a_date?(maybe_date)
          Date.parse maybe_date.to_s
          true
        rescue ArgumentError
          false
        end

        def date_start_is_not_in_the_past
          if date_start_is_in_the_past?
            errors.add :date_start, :should_not_be_in_past
          end
        end

        def date_start_is_in_the_past?
          date_start < Date.today
        end

        def date_end_not_before_date_start
          unless date_end_not_before_date_start?
            errors.add :date_end, :should_not_be_before_date_start
          end
        end

        def date_end_not_before_date_start?
          date_end > date_start
        end

        def objectives_not_too_long
          if objectives_too_long?
            errors.add :objectives, :use_fifty_words_or_fewer
          end
        end

        def objectives_too_long?
          objectives.scan(/\w/).size > MAX_WORDS_FOR_OBJECTIVE
        end
      end
    end
  end
end
