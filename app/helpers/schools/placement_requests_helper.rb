module Schools::PlacementRequestsHelper
  HIDDEN_STATUSES = %w(Viewed Booked).freeze

  def placement_request_status(placement_request)
    status = placement_request.status

    unless status.in? HIDDEN_STATUSES

      css_class = if placement_request.cancelled?
                    'govuk-tag-red'
                  else
                    'govuk-tag'
                  end

      tag.span status, class: css_class
    end
  end

  def cancellation_noun(cancellation)
    if cancellation.cancelled_by_candidate?
      'Withdrawal'
    elsif cancellation.cancelled_by_school?
      'Rejection'
    else
      fail 'cancellation not sent'
    end
  end
end
