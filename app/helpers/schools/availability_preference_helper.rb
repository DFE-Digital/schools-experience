module Schools::AvailabilityPreferenceHelper
  # always show future dates so the user won't be
  # confused by being shown past dates
  def example_future_dates
    future_date = 1.month.from_now.monday.to_date
    [future_date, future_date + 1.day]
  end
end
