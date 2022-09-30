module Schools::PlacementRequestsHelper
  HIDDEN_STATUSES = %w[Viewed Booked].freeze

  def placement_request_status(placement_request)
    status = placement_request.status

    unless status.in? HIDDEN_STATUSES

      css_class = if placement_request.cancelled?
                    'govuk-tag govuk-tag--red'
                  elsif status == 'Flagged'
                    'govuk-tag govuk-tag--yellow'
                  elsif placement_request.expired?
                    'govuk-tag govuk-tag--grey'
                  elsif status == 'Under consideration'
                    'govuk-tag govuk-tag--blue'
                  else
                    'govuk-tag govuk-tag--green'
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
      raise 'cancellation not sent'
    end
  end

  def cancellation_reasons(cancellation)
    tag.ul(class: "govuk-list govuk-list--bullet") do |_ul|
      safe_join(
        Array.wrap(cancellation.humanised_rejection_categories).map { |r| tag.li(r) }
      )
    end
  end
end
