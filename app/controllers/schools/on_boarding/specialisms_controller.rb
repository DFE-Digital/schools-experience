module Schools
  module OnBoarding
    class SpecialismsController < OnBoardingsController
      def new
        @specialism = Specialism.new
      end

      def create
        @specialism = Specialism.new specialism_params

        if @specialism.valid?
          current_school_profile.update! specialism: @specialism
          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

    private

      def specialism_params
        params.require(:schools_on_boarding_specialism).permit \
          :has_specialism,
          :details
      end
    end
  end
end
