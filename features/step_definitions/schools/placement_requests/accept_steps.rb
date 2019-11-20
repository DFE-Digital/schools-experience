Given("there is a new placement request") do
  @profile = FactoryBot.create(:bookings_profile, school: @school)
  @placement_request = FactoryBot.create(:bookings_placement_request, school: @school)
end

Given("I am on the accept placement request page") do
  path = path_for("accept placement request", placement_request: @placement_request)
  visit(path)
  expect(page.current_path).to eql(path)
end

Then("every row of the booking details list should have a {string} link") do |string|
  within('#booking-details') do
    page.all('div.govuk-summary-list__row').each do |row|
      expect(row).to have_link(string)
    end
  end
end

Given("there is a new placement request with a future date") do
  @profile = FactoryBot.create(:bookings_profile, school: @school)
  placement_date = FactoryBot.create(:bookings_placement_date, bookings_school: @school)
  @placement_request = FactoryBot.create(:bookings_placement_request, school: @school, placement_date: placement_date)
end

Given("there is a new placement request with a past date") do
  @profile = FactoryBot.create(:bookings_profile, school: @school)
  placement_date = FactoryBot.create(:bookings_placement_date, :in_the_past, bookings_school: @school)
  @placement_request = FactoryBot.create(:bookings_placement_request, school: @school, placement_date: placement_date)
end


When("I am on the {string} screen for that placement request") do |string|
  path = path_for(string, placement_request: @placement_request)
  visit(path)
  expect(page.current_path).to eql(path)
end

Then("the {string} link should take me to the {string} page") do |link_text, screen|
  expect(page).to have_link(
    link_text,
    href: path_for(screen, placement_request: @placement_request)
  )
end
