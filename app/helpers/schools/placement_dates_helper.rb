module Schools::PlacementDatesHelper
  def display_status(val)
    val ? "Available" : "Taken"
  end
end
