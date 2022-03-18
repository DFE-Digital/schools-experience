module Schools::PlacementDatesHelper
  def placement_date_status_tag(placement_date)
    availability_end_date_in_future = (placement_date.date - placement_date.end_availability_offset).future?

    if placement_date.available?
      tag.strong "Open", class: "govuk-tag govuk-tag--available"
    elsif placement_date.active && availability_end_date_in_future
      tag.strong "Scheduled", class: "govuk-tag govuk-tag--grey"
    else
      tag.strong "Closed", class: "govuk-tag govuk-tag--taken"
    end
  end

  def availability_status_display_status(val)
    val ? "fixed dates" : "flexible dates"
  end

  def show_subject_support_option(school)
    options = school.phases.map(&:supports_subjects)

    [true, false].all? { |value| value.in?(options) }
  end

  def placement_date_subject_description(placement_date)
    if placement_date.subject_specific?
      placement_date.subjects.pluck(:name).join(', ')
    elsif placement_date.supports_subjects?
      'All subjects'
    else
      'Primary'
    end
  end

  def placement_date_phase(placement_date)
    placement_date.supports_subjects ? "Secondary" : "Primary"
  end

  def placement_date_anchor(placement_date)
    "#{placement_date_phase(placement_date)}-placement-date-#{placement_date.date}".downcase
  end

  def placement_date_experience_type_tag(virtual)
    virtual ? placement_date_virtual_tag : placement_date_inschool_tag
  end

  def placement_date_virtual_tag
    tag.strong "Virtual", class: "govuk-tag govuk-tag--green"
  end

  def placement_date_inschool_tag
    tag.strong "In school", class: "govuk-tag govuk-tag--yellow"
  end

  def close_date_link(placement_date)
    link_to("Close", schools_placement_date_close_path(placement_date.id)) if placement_date.available?
  end
end
