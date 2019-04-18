module Schools
  module OnBoarding
    class PhasesListsController < OnBoardingsController
      def new
        @phases_list = PhasesList.new
      end

      def create
        @phases_list = PhasesList.new phases_list_params

        if @phases_list.valid?
          current_school_profile.update! phases_list: @phases_list
          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

      def edit
        @phases_list = current_school_profile.phases_list
      end

      def update
        @phases_list = PhasesList.new phases_list_params

        if @phases_list.valid?
          current_school_profile.update! phases_list: @phases_list
          redirect_to next_step_path(current_school_profile)
        else
          render :edit
        end
      end

    private

      def phases_list_params
        params.require(:schools_on_boarding_phases_list).permit \
          :primary,
          :secondary,
          :college
      end
    end
  end
end
