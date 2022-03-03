module Schools
  module OnBoarding
    class CandidateExperienceDetail < Step
      # Ensure that times look *roughly* valid. Note that it is
      # still possible to input invalid ones like '25:00'.
      # FIXME do we need to tighten this up/use a real timepicker?
      SCHOOL_TIME_FORMAT = %r{\A((\d{1,2})(?:(\.|:))(\d{1,2})\s*((?:(am|pm)))?)|\A([\d{1,2}]\s*(am|pm))|\A\d{1,2}\z}i.freeze

      attribute :parking_provided, :boolean
      attribute :parking_details, :string
      attribute :nearby_parking_details, :string
      attribute :start_time, :string
      attribute :end_time, :string
      attribute :times_flexible, :boolean
      attribute :times_flexible_details, :string

      validates :parking_provided, inclusion: [true, false]
      validates :parking_details, presence: true, if: :parking_provided
      validates :nearby_parking_details, presence: true, if: -> { !parking_provided && !parking_provided.nil? }
      validates :start_time, presence: true
      validates :start_time, format: { with: SCHOOL_TIME_FORMAT }, if: -> { start_time.present? }
      validates :end_time, presence: true
      validates :end_time, format: { with: SCHOOL_TIME_FORMAT }, if: -> { end_time.present? }
      validates :times_flexible, inclusion: [true, false]
      validates :times_flexible_details, presence: true, if: :times_flexible

      def self.compose(
        parking_provided,
        parking_details,
        nearby_parking_details,
        start_time,
        end_time,
        times_flexible,
        times_flexible_details
      )
        new \
          parking_provided: parking_provided,
          parking_details: parking_details,
          nearby_parking_details: nearby_parking_details,
          start_time: start_time,
          end_time: end_time,
          times_flexible: times_flexible,
          times_flexible_details: times_flexible_details
      end
    end
  end
end
