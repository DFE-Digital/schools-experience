module Schools
  module OnBoarding
    class CandidateExperienceDetail
      include ActiveModel::Model
      include ActiveModel::Attributes

      # Ensure that times look *roughly* valid. Note that it is
      # still possible to input invalid ones like '25:00'.
      # FIXME do we need to tighten this up/use a real timepicker?
      SCHOOL_TIME_FORMAT = %r{\A((\d{1,2}):(\d{1,2})\s*((?:(am|pm)))?)|\A([\d{1,2}]\s*(am|pm))}i.freeze

      attribute :business_dress, :boolean, default: false
      attribute :cover_up_tattoos, :boolean, default: false
      attribute :remove_piercings, :boolean, default: false
      attribute :smart_casual, :boolean, default: false
      attribute :other_dress_requirements, :boolean, default: false
      attribute :other_dress_requirements_detail, :string
      attribute :parking_provided, :boolean
      attribute :parking_details, :string
      attribute :nearby_parking_details, :string
      attribute :disabled_facilities, :boolean
      attribute :disabled_facilities_details, :string
      attribute :start_time, :string
      attribute :end_time, :string
      attribute :times_flexible, :boolean

      validates :business_dress, inclusion: [true, false]
      validates :cover_up_tattoos, inclusion: [true, false]
      validates :remove_piercings, inclusion: [true, false]
      validates :smart_casual, inclusion: [true, false]
      validates :other_dress_requirements, inclusion: [true, false]
      validates :other_dress_requirements_detail, presence: true, if: :other_dress_requirements
      validates :parking_provided, inclusion: [true, false]
      validates :parking_details, presence: true, if: :parking_provided
      validates :nearby_parking_details, presence: true, if: -> { !parking_provided && !parking_provided.nil? }
      validates :disabled_facilities, inclusion: [true, false]
      validates :disabled_facilities_details, presence: true, if: :disabled_facilities
      validates :times_flexible, inclusion: [true, false]
      validates :start_time, presence: true
      validates :start_time, format: { with: SCHOOL_TIME_FORMAT }, if: -> { start_time.present? }
      validates :end_time, presence: true
      validates :end_time, format: { with: SCHOOL_TIME_FORMAT }, if: -> { end_time.present? }

      def self.compose(
          business_dress,
          cover_up_tattoos,
          remove_piercings,
          smart_casual,
          other_dress_requirements,
          other_dress_requirements_detail,
          parking_provided,
          parking_details,
          nearby_parking_details,
          disabled_facilities,
          disabled_facilities_details,
          start_time,
          end_time,
          times_flexible
      )
        new \
          business_dress: business_dress,
          cover_up_tattoos: cover_up_tattoos,
          remove_piercings: remove_piercings,
          smart_casual: smart_casual,
          other_dress_requirements: other_dress_requirements,
          other_dress_requirements_detail: other_dress_requirements_detail,
          parking_provided: parking_provided,
          parking_details: parking_details,
          nearby_parking_details: nearby_parking_details,
          disabled_facilities: disabled_facilities,
          disabled_facilities_details: disabled_facilities_details,
          start_time: start_time,
          end_time: end_time,
          times_flexible: times_flexible
      end

      def ==(other)
        other.respond_to?(:attributes) && other.attributes == self.attributes
      end
    end
  end
end
