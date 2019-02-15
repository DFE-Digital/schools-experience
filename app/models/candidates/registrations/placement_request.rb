module Candidates
  module Registrations
    class PlacementRequest < ApplicationRecord
      include Validations::PlacementPreferenceValidations
    end
  end
end
