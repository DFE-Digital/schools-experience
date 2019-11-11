module Schools
  class FeedbacksController < BaseController
    skip_before_action :ensure_onboarded

    def show; end

    def new
      @feedback = Schools::Feedback.new referrer_params
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

    def referrer_params
      { referrer: request.env['HTTP_REFERER'] }
    end

    def feedback_params
      params.require(:schools_feedback).permit \
        :reason_for_using_service,
        :reason_for_using_service_explanation,
        :rating,
        :improvements,
        :successful_visit,
        :unsuccessful_visit_explanation,
        :referrer
    end
  end
end
