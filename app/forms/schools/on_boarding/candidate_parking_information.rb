module Schools
  module OnBoarding
    class CandidateParkingInformation < Step
      attribute :parking_provided, :boolean
      attribute :parking_details, :string
      attribute :nearby_parking_details, :string

      validates :parking_provided, inclusion: [true, false]
      validates :parking_details, presence: true, if: :parking_provided
      validates :nearby_parking_details, presence: true, if: -> { !parking_provided && !parking_provided.nil? }

      def self.compose(
        parking_provided,
        parking_details,
        nearby_parking_details
      )
        new \
          parking_provided: parking_provided,
          parking_details: parking_details,
          nearby_parking_details: nearby_parking_details
      end
    end
  end
end
