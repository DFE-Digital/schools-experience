module Schools
  class FeedbacksController < BaseController
    skip_before_action :ensure_onboarded

    def show
      @feedback = Schools::Feedback.find params[:id]
    end

    def new
      @feedback = Schools::Feedback.new
    end

    def create
      @feedback = Schools::Feedback.new \
        feedback_params.merge(urn: current_school&.urn)

      if @feedback.save
        redirect_to @feedback
      else
        render :new
      end
    end

  private

    def feedback_params
      params.require(:schools_feedback).permit \
        :reason_for_using_service,
        :reason_for_using_service_explanation,
        :rating,
        :improvements,
        :successful_visit,
        :unsuccessful_visit_explanation
    end
  end
end
