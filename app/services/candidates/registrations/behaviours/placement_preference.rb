module Candidates
  module Registrations
    module Behaviours
      module PlacementPreference
        extend ActiveSupport::Concern

        included do
          validates :urn, presence: true
          validates :objectives, presence: true
          validates :objectives, number_of_words: { less_than: 150 }, if: -> { objectives.present? }
        end
      end
    end
  end
end
