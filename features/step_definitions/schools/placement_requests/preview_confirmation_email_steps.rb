When("I enter some candidate instructions") do
  @candidate_instructions = 'Please come to the reception in the East Building'
  step "I enter '#{@candidate_instructions}' into the 'Candidate instructions' text area"
end

Then("the extra details from the school section should contain the relevant information") do
  within('#extra-details-from-the-school') do
    expect(page).to have_content(@candidate_instructions)
  end
end

Then("the placement request should be accepted") do
  expect(@placement_request.reload.booking.accepted_at).not_to be_nil
end

Given("I am have progressed to the {string} page for the placement request") do |string|
  @booking = FactoryBot.create(:bookings_booking, bookings_placement_request: @placement_request)
  path = path_for(string, placement_request: @placement_request)
  visit(path)
  expect(page.current_path).to eql(path)
end

Then("I should see an email preview that has the following sections:") do |table|
  table.transpose.raw.flatten.each do |row|
    expect(page).to have_css('h3', text: row)
  end
end

Given("I enter nothing into the {string} text area") do |string|
  # Do nothing
end
