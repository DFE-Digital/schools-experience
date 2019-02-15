module Candidates
  module Registrations
    class PlacementRequest < ApplicationRecord
      include Behaviours::PlacementPreference
      include Behaviours::SubjectPreference
      include Behaviours::BackgroundCheck
    end
  end
end
