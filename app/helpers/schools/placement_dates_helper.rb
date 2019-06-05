module Schools::PlacementDatesHelper
  def placement_date_display_status(val)
    val ? "Open" : "Closed"
  end

  def availability_status_display_status(val)
    val ? "fixed dates" : "flexible dates"
  end

  def placement_date_display_class(val)
    val ? "govuk-tag--available" : "govuk-tag--taken"
  end
end
