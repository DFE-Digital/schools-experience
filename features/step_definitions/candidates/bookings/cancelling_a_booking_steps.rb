Given "I have a booking" do
  @placement_request = FactoryBot.create :placement_request
  @booking = FactoryBot.create :bookings_booking, bookings_placement_request: @placement_request
end

When "I visit the bookings cancellation link" do
  visit "/candidates/cancel/#{@booking.token}"
end

Given("I have a cancelled booking") do
  FactoryBot.create :cancellation, \
    :sent, :cancelled_by_school,
    placement_request: @booking.bookings_placement_request
end
