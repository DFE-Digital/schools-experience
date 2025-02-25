module Schools
  module OnBoarding
    class ExperienceOutlinesController < OnBoardingsController
      def new
        @experience_outline = \
          ExperienceOutline.new_from_bookings_school current_school
      end

      def create
        @experience_outline = ExperienceOutline.new experience_outline_params

        if @experience_outline.valid?
          current_school_profile.update! experience_outline: @experience_outline
          continue(current_school_profile)
        else
          render :new
        end
      end

      def edit
        @experience_outline = duplicate_if_frozen(current_school_profile.experience_outline)
      end

      def update
        @experience_outline = ExperienceOutline.new experience_outline_params

        if @experience_outline.valid?
          current_school_profile.update! experience_outline: @experience_outline
          continue(current_school_profile)
        else
          render :edit
        end
      end

    private

      def experience_outline_params
        params.require(:schools_on_boarding_experience_outline).permit \
          :candidate_experience
      end
    end
  end
end
