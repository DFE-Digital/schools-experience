module Candidates
  class BookingFeedbacksController < ApplicationController
    before_action :ensure_booking_attended, :ensure_feedback_not_provided, except: [:show]

    def new
      @feedback = Candidates::BookingFeedback.new
    end

    def create
      @feedback = Candidates::BookingFeedback.new(
        feedback_params.merge(booking: placement_request.booking)
      )

      if @feedback.save
        redirect_to(@feedback)
      else
        render :new
      end
    end

    def show; end

  private

    def ensure_booking_attended
      render :booking_not_attended unless booking&.attended?
    end

    def ensure_feedback_not_provided
      render :feedback_already_provided if booking&.candidate_feedback.present?
    end

    def feedback_params
      params.require(:candidates_booking_feedback).permit(
        :gave_realistic_impression,
        :covered_subject_of_interest,
        :influenced_decision,
        :intends_to_apply,
        :effect_on_decision
      )
    end

    def placement_request
      @placement_request ||= Bookings::PlacementRequest.find_by!(
        token: params[:booking_token]
      )
    end

    def booking
      placement_request.booking
    end
  end
end
