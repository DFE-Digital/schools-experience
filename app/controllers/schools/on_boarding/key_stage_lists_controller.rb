module Schools
  module OnBoarding
    class KeyStageListsController < OnBoardingsController
      def new
        @key_stage_list = KeyStageList.new_from_bookings_school current_school
      end

      def create
        @key_stage_list = KeyStageList.new key_stage_list_params

        if @key_stage_list.valid?
          current_school_profile.update! key_stage_list: @key_stage_list
          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

      def edit
        @key_stage_list = current_school_profile.key_stage_list
      end

      def update
        @key_stage_list = KeyStageList.new key_stage_list_params

        if @key_stage_list.valid?
          current_school_profile.update! key_stage_list: @key_stage_list
          redirect_to next_step_path(current_school_profile)
        else
          render :edit
        end
      end

    private

      def key_stage_list_params
        params.require(:schools_on_boarding_key_stage_list).permit \
          :early_years,
          :key_stage_1,
          :key_stage_2
      end
    end
  end
end
