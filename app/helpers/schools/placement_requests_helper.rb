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
end
