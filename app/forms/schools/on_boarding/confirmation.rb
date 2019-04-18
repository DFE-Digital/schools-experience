module Schools
  module OnBoarding
    class Confirmation
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :acceptance, :boolean
      validates :acceptance, acceptance: true
    end
  end
end
