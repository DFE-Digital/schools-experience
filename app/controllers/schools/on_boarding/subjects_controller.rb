module Schools
  module OnBoarding
    class SubjectsController < OnBoardingsController
      def new
        @subject_list = SubjectList.new_from_bookings_school current_school
      end

      def create
        @subject_list = SubjectList.new subjects_params

        if @subject_list.valid?
          current_school_profile.update! subject_ids: @subject_list.subject_ids

          continue(current_school_profile)
        else
          render :new
        end
      end

      def edit
        @subject_list = SubjectList.new \
          subject_ids: current_school_profile.subject_ids
      end

      def update
        @subject_list = SubjectList.new subjects_params

        if @subject_list.valid?
          current_school_profile.update! subject_ids: @subject_list.subject_ids

          continue(current_school_profile)
        else
          render :edit
        end
      end

    private

      def subjects_params
        params.require(:schools_on_boarding_subject_list).permit \
          subject_ids: []
      end
    end
  end
end
