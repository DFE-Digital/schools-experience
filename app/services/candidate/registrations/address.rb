module Candidate
  module Registrations
    class Address
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :building, :string
      attribute :street, :string
      attribute :town_or_city, :string
      attribute :county, :string
      attribute :postcode, :string
      attribute :phone, :string

      validates :building, presence: true
      validates :street, presence: true
      validates :town_or_city, presence: true
      validates :county, presence: true
      validates :postcode, presence: true
      validates :phone, presence: true
    end
  end
end
