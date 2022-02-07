Given "I have an attended booking" do
  placement_request = FactoryBot.create(:placement_request, :with_attended_booking)
  @booking = placement_request.booking
end

When "I visit the booking feedback link" do
  visit new_candidates_booking_feedback_path(@booking.token)
end
