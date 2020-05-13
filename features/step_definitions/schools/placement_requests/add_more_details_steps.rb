Given("I have progressed to the {string} page for my chosen placement request") do |string|
  expect(page.current_path).to eql(path_for(string, placement_request: @placement_request))
end

Given("I have completed the 'confirm booking' page") do
  steps %(
    Given I am on the 'confirm booking' page for my chosen placement request
    And I enter three weeks from now as the date
    And I select 'Chemistry' from the 'Confirm subject' select box
    And I enter "It's a really exciting day" into the "Confirm experience details" text area
    When I submit the form
    Then I should be on the 'add more details' page for my chosen placement request
  )
end

Then("the subheading should be {string}") do |subheading|
  expect(page).to have_css('h3', text: subheading)
end

Then("there should be a link back to the placement request") do
  expect(page).to have_link('Back to request', href: schools_placement_request_path(@placement_request.id))
end

Then("the relevant fields in the booking should have been saved") do
  @placement_request.booking.tap do |b|
    expect(b.contact_name).to eql('Dewey Largo')
    expect(b.contact_number).to eql('01234 567 890')
    expect(b.contact_email).to eql('dlargo@springfield.edu')
    expect(b.location).to eql('Please come to the reception in the East Building')
  end
end

Given("my school has previous accepted bookings") do
  @latest_accepted_booking = FactoryBot.create(
    :bookings_booking,
    :accepted,
    :with_more_details_added,
    bookings_school: @school
  )
end

Then("the contact details should have been filled with those from the latest accepted booking") do
  {
    "Contact name" => @latest_accepted_booking.contact_name,
    "Contact number" => @latest_accepted_booking.contact_number,
    "Contact email" => @latest_accepted_booking.contact_email,
  }.each do |label, value|
    expect(get_input(page, label)['value']).to eql(value)
  end

  within(get_form_group(page, 'Location')) do
    expect(page.find('textarea')['value']).to eql(@latest_accepted_booking.location)
  end
end
