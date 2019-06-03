module Schools
  module PlacementRequests
    class AddMoreDetails
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :contact_name
      attribute :contact_number
      attribute :contact_email
      attribute :location

      validates :contact_name, presence: true
      validates :contact_number, presence: true
      attribute :contact_email, presence: true
      attribute :location, presence: true
    end
  end
end
