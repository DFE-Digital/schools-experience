module Schools
  module OnBoarding
    class TeacherTrainingsController < OnBoardingsController
      def new
        @teacher_training = \
          TeacherTraining.new_from_bookings_school current_school
      end

      def create
        @teacher_training = TeacherTraining.new teacher_training_params

        if @teacher_training.valid?
          current_school_profile.update! teacher_training: @teacher_training
          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

      def edit
        @teacher_training = current_school_profile.teacher_training
      end

      def update
        @teacher_training = TeacherTraining.new teacher_training_params

        if @teacher_training.valid?
          current_school_profile.update! teacher_training: @teacher_training
          redirect_to next_step_path(current_school_profile)
        else
          render :edit
        end
      end

    private

      def teacher_training_params
        params.require(:schools_on_boarding_teacher_training).permit \
          :provides_teacher_training,
          :teacher_training_details,
          :teacher_training_url
      end
    end
  end
end
