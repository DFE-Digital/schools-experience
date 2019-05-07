module Candidates
  class SchoolPresenter
    include ActionView::Helpers::TextHelper

    attr_reader :school, :profile

    delegate :name, :urn, :coordinates, :website, to: :school
    delegate :availability_preference_fixed?, to: :school

    delegate :placement_info, :individual_requirements, to: :profile
    delegate :specialism_details, :disabled_facilities, to: :profile
    delegate :teacher_training_info, :teacher_training_url, to: :profile
    delegate :dbs_required, :parking_provided, :parking_details, to: :profile
    delegate :start_time, :end_time, :flexible_on_times, to: :profile
    delegate :dress_code_other_details, to: :profile

    def initialize(school, profile)
      @school = school
      @profile = profile
    end

    def dress_code
      profile.attributes.map do |key, value|
        if key.to_s =~ /dress_code_/ &&
          key.to_s != 'dress_code_other_details' &&
          value == true

          profile.class.human_attribute_name(key)
        end
      end.compact.join(', ')
    end

    def dress_code?
      dress_code_other_details.present? || dress_code.present?
    end

    def formatted_dress_code
      return unless dress_code?

      simple_format [ dress_code, dress_code_other_details ].join("\n\n")
    end
  end
end
