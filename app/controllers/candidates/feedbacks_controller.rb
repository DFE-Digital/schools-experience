module Candidates
  class FeedbacksController < ApplicationController
    def show; end

    def new
      @feedback = Candidates::Feedback.new
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

    def feedback_params
      params.require(:candidates_feedback).permit \
        :reason_for_using_service,
        :reason_for_using_service_explanation,
        :rating,
        :improvements
    end
  end
end
