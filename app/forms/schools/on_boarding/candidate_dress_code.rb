module Schools
  module OnBoarding
    class CandidateDressCode < Step
      attribute :business_dress, :boolean, default: false
      attribute :cover_up_tattoos, :boolean, default: false
      attribute :remove_piercings, :boolean, default: false
      attribute :smart_casual, :boolean, default: false
      attribute :other_dress_requirements, :boolean, default: false
      attribute :other_dress_requirements_detail, :string

      validates :business_dress, inclusion: [true, false]
      validates :cover_up_tattoos, inclusion: [true, false]
      validates :remove_piercings, inclusion: [true, false]
      validates :smart_casual, inclusion: [true, false]
      validates :other_dress_requirements, inclusion: [true, false]
      validates :other_dress_requirements_detail, presence: true, if: :other_dress_requirements

      def self.compose(
        business_dress,
        cover_up_tattoos,
        remove_piercings,
        smart_casual,
        other_dress_requirements,
        other_dress_requirements_detail
      )
        new \
          business_dress: business_dress,
          cover_up_tattoos: cover_up_tattoos,
          remove_piercings: remove_piercings,
          smart_casual: smart_casual,
          other_dress_requirements: other_dress_requirements,
          other_dress_requirements_detail: other_dress_requirements_detail
      end
    end
  end
end
