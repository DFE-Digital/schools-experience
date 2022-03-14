module Candidates::DashboardHelper
  def status_tag(status, colour)
    tag.span status, class: "govuk-tag #{colour}"
  end

  def review_or_cancel_placement_link(action, token)
    case action
    when :cancel then cancel_placement_link(token)
    when :review then review_experience_link(token)
    end
  end

  def cancel_placement_link(token)
    link_to "Cancel", candidates_cancel_url(token), 'aria-label': "Cancel placement"
  end

  def review_experience_link(token)
    link_to "Review", new_candidates_booking_feedback_url(token), 'aria-label': "Review experience"
  end
end
