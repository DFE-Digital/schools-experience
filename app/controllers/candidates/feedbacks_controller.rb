module Candidates
  class FeedbacksController < ApplicationController
    def show; end

    def new
      @feedback = Candidates::Feedback.new referrer_params
    end

    def create
      @feedback = Candidates::Feedback.new feedback_params

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
      params.require(:candidates_feedback).permit \
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
