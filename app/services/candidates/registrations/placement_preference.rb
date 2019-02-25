module Candidates
  module Registrations
    class PlacementPreference < RegistrationStep
      # This allows us to parse multi-part date parameters like an ActiveRecord object.
      include ActiveRecord::AttributeAssignment
      class ActiveModel::Type::Date
        def default_timezone
          :utc
        end
      end

      include Behaviours::PlacementPreference

      attribute :date_start, :date
      attribute :date_end, :date
      attribute :objectives, :string
    end
  end
end
