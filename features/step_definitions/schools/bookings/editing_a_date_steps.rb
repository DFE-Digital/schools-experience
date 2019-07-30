When("I am on the {string} page for my booking") do |string|
  path = path_for(string, booking_id: @booking_id)
  visit(path)
  expect(page.current_path).to eql(path)
end

Then("I should be on the show page for my booking") do
  path = path_for('booking', booking_id: @booking_id)
  expect(page.current_path).to eql(path)
end

Then("I should see a {string} link to the show page for my booking") do |string|
  expect(page).to have_link(string, href: schools_booking_path(@booking_id))
end

When("I change the date to one two weeks in the future") do
  @new_date = 2.weeks.from_now.to_date
  step "I fill in the date field 'Booking date' with #{@new_date.strftime('%d-%m-%Y')}"
end

Then("the date should have been updated") do
  expect(@booking.reload.date).to eql(@new_date)
end
