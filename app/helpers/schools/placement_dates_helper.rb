module Schools::PlacementDatesHelper
  def placement_date_display_status(val)
    val ? "Available" : "Taken"
  end

  def placement_date_display_class(val)
    val ? "govuk-tag--available" : "govuk-tag--taken"
  end
end
