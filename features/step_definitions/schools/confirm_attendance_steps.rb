Given("there are some bookings that were scheduled last week") do
  @number_of_bookings = 3
  step "there are #{@number_of_bookings} bookings"
  @bookings.each do |booking|
    booking.date = booking.accepted_at = 4.days.ago
    booking.save(validate: false)
  end
  @first_booking = @bookings.first
end

Then("I should see a table containing those bookings") do
  expect(page).to have_css('table > tbody > tr', count: @number_of_bookings)
end

Then("the correct data should be present in each row") do
  gitis = Bookings::Gitis::CRM.new('a.fake.token')

  within("table > tbody > tr[data-booking-id='#{@first_booking.id}']") do
    expect(page).to have_content(
      @first_booking.bookings_placement_request.fetch_gitis_contact(gitis).full_name
    )
    expect(page).to have_content(@first_booking.date.strftime('%d %B %Y'))
    expect(page).to have_content(@first_booking.bookings_subject.name)
  end
end

When("I select {string} for the first booking") do |option|
  within("table > tbody > tr[data-booking-id='#{@first_booking.id}']") do
    choose option
  end
end

Then("the booking should be marked as attended") do
  expect(@bookings.first.reload).to be_attended
end

Then("the booking should be marked as not attended") do
  expect(@bookings.first.reload.attended).to be(false)
end

Given("I have set a booking to be attended") do
  steps %(
    Given there are some bookings that were scheduled last week
    And I am on the 'confirm attendance' page
    When I select 'No' for the first booking
    And I click the 'Save and return to requests and bookings' submit button
    Then I should be on the 'schools dashboard' page
    And the booking should be marked as not attended
  )
end

Then("the other bookings should not be updated") do
  other_bookings = @bookings.reject { |b| b == @first_booking }

  expect(other_bookings.size).to eql(@number_of_bookings - 1)
  other_bookings.map(&:attended).each do |ob|
    expect(ob).to be_nil
  end
end
