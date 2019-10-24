When("I am on the {string} page for my booking") do |string|
  path = path_for(string, booking_id: @booking_id)
  visit(path)
  expect(page.current_path).to eql(path)
end

Then("I should be on the date changed confirmation page") do
  path = path_for('booking date changed', booking_id: @booking_id)
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

Given("I have changed a booking date") do
  steps %(
      Given there is at least one booking
      And I am on the 'change booking date' page for my booking
      When I change the date to one two weeks in the future
      And I submit the form
      Then I should be on the date changed confirmation page
      And the date should have been updated
  )
end

Then("the page should contain the new booking date") do
  expect(page).to have_content(@new_date.to_formatted_s(:govuk))
end

Then("there should be a link to the {string} screen") do |string|
  expect(page).to have_link(string, href: path_for('bookings'))
end

When("I change the date to an invalid date") do
  step "I fill in the date field 'Booking date' with 200-100-900"
end
