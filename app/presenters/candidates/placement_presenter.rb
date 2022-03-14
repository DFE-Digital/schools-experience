module Candidates
  class PlacementPresenter
    attr_reader :placement_request, :booking

    def initialize(placement_request)
      @placement_request = placement_request
      @booking = placement_request.booking
    end

    def date
      return booked_date if booking&.date

      requested_date
    end

    def status
      @status ||=
        if booking&.attended == true
          'Attended'
        elsif booking&.attended == false
          'Not attended'
        elsif placement_request.status.in? ['Under consideration', 'Flagged', 'Viewed', 'New']
          'Pending'
        else
          placement_request.status
        end
    end

    def status_tag_colour
      {
        'Withdrawn' => 'govuk-tag--orange',
        'Candidate cancellation' => 'govuk-tag--orange',
        'School cancellation' => 'govuk-tag--orange',
        'Expired' => 'govuk-tag--yellow',
        'Not attended' => 'govuk-tag--yellow',
        'Rejected' => 'govuk-tag--red',
        'Booked' => 'govuk-tag--blue',
        'Attended' => 'govuk-tag--green',
        'Pending' => 'govuk-tag--grey'
      }[status]
    end

    def placement_action
      if attended_but_unreviewed_experience?
        :review
      elsif future_booking? || pending_placement?
        :cancel
      end
    end

  private

    def attended_but_unreviewed_experience?
      status == 'Attended' && booking&.candidate_feedback.nil?
    end

    def future_booking?
      status == 'Booked' && booking.date >= Time.zone.now
    end

    def pending_placement?
      status == 'Pending'
    end

    def requested_date
      return 'Pending' if placement_request.flex_date?

      placement_request.fixed_date.to_formatted_s(:govuk)
    end

    def booked_date
      booking&.date&.to_formatted_s(:govuk)
    end
  end
end
