module Schools
  module OnBoarding
    class CandidateExperienceSchedulesController < OnBoardingsController
      def new
        @candidate_experience_schedule = CandidateExperienceSchedule.new
      end

      def create
        @candidate_experience_schedule = CandidateExperienceSchedule.new \
          candidate_experience_schedule_params

        if @candidate_experience_schedule.valid?
          current_school_profile.update! \
            candidate_experience_schedule: @candidate_experience_schedule

          continue(current_school_profile)
        else
          render :new
        end
      end

      def edit
        # NB: we must initialise new models when editing an existing one because
        # we are using the composed_of framework to build the components of
        # SchoolProfile. Otherwise, frozen variable errors will be triggered.
        @candidate_experience_schedule = \
          CandidateExperienceSchedule.new(current_school_profile.candidate_experience_schedule.attributes)
      end

      def update
        @candidate_experience_schedule = CandidateExperienceSchedule.new \
          candidate_experience_schedule_params

        if @candidate_experience_schedule.valid?
          current_school_profile.update! \
            candidate_experience_schedule: @candidate_experience_schedule

          continue(current_school_profile)
        else
          render :edit
        end
      end

    private

      def candidate_experience_schedule_params
        params.require(:schools_on_boarding_candidate_experience_schedule).permit \
          :start_time,
          :end_time,
          :times_flexible,
          :times_flexible_details
      end
    end
  end
end
