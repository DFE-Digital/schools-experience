module Schools
  module OnBoarding
    class CandidateDressCode < Step
      attribute :selected_requirements, default: []
      attribute :other_dress_requirements_detail, :string

      validates :other_dress_requirements_detail, presence: true, if: :other_dress_requirements?
      validate :dress_code_requirements_or_none_selected

      def self.compose(
        business_dress,
        cover_up_tattoos,
        remove_piercings,
        smart_casual,
        other_dress_requirements,
        other_dress_requirements_detail
      )
        selected_requirements = []

        selected_requirements << "business_dress" if business_dress
        selected_requirements << "cover_up_tattoos" if cover_up_tattoos
        selected_requirements << "remove_piercings" if remove_piercings
        selected_requirements << "smart_casual" if smart_casual
        selected_requirements << "other_dress_requirements" if other_dress_requirements

        # Comparing explicitly to false because a nil attribute shouldn't infer "none".
        if [
          business_dress,
          cover_up_tattoos,
          remove_piercings,
          smart_casual,
          other_dress_requirements
        ].all?(false)
          selected_requirements << "none"
        end

        new(selected_requirements: selected_requirements, other_dress_requirements_detail: other_dress_requirements_detail)
      end

      def business_dress?
        selected_requirements.include?("business_dress")
      end

      def cover_up_tattoos?
        selected_requirements.include?("cover_up_tattoos")
      end

      def remove_piercings?
        selected_requirements.include?("remove_piercings")
      end

      def smart_casual?
        selected_requirements.include?("smart_casual")
      end

      def other_dress_requirements?
        selected_requirements.include?("other_dress_requirements")
      end

      def none?
        selected_requirements.include?("none")
      end

    private

      def dress_code_requirements_or_none_selected
        # selected_requirements will always contain an empty string from the form body
        requirements = selected_requirements.reject(&:empty?)
        no_options_selected = requirements.empty?
        requirements_and_none_selected = none? && requirements.count > 1

        if no_options_selected || requirements_and_none_selected
          errors.add(:selected_requirements, :no_requirements_selected)
        end
      end
    end
  end
end
