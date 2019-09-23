module Schools::PlacementRequestsHelper
  def placement_request_status(placement_request)
    fail "not applicable for bookings" if placement_request.booking

    text = placement_request.status unless placement_request.status == 'Viewed'

    tag.span(text, class: 'govuk-tag') if text
  end
end
