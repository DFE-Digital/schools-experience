module Schools::PlacementRequestsHelper
  def placement_request_status(placement_request)
    text = if placement_request.cancelled?
             'Cancelled'
           elsif !placement_request.viewed?
             'New'
           end

    tag.span(text, class: 'govuk-tag') if text
  end
end
