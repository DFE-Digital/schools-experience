module Schools
  module PlacementDates
    class CloseConfirmationForm
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :confirmed, default: true
    end
  end
end
