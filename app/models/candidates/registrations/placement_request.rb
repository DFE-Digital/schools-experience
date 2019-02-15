module Candidates
  module Registrations
    class PlacementRequest < ApplicationRecord
      include Behaviours::PlacementPreference
      include Behaviours::SubjectPreference
    end
  end
end
