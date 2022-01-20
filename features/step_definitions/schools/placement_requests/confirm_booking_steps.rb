Given("I am on the {string} page for my chosen placement request") do |identifier|
  @placement_request = FactoryBot.create(:bookings_placement_request, school: @school)

  path = path_for(identifier, placement_request: @placement_request)
  visit(path)
  expect(page.current_path).to eql(path)
end

Then("I should be on the {string} page for my chosen placement request") do |identifier|
  path = path_for(identifier, placement_request: @placement_request)
  expect(page.current_path).to eql(path)
end

When("I am on the {string} page for my fixed placement request") do |identifier|
  @school.update(availability_preference_fixed: true)
  @placement_date = FactoryBot.create(:bookings_placement_date, bookings_school: @school)
  @placement_request = FactoryBot.create(
    :bookings_placement_request,
    school: @school,
    placement_date: @placement_date
  )

  path = path_for(identifier, placement_request: @placement_request)
  visit(path)
  expect(page.current_path).to eql(path)
end

Then("the subheading should be {string} followed by the candidate's name") do |subheading|
  api = GetIntoTeachingApiClient::SchoolsExperienceApi.new
  contact = api.get_schools_experience_sign_up(@placement_request.contact_uuid)

  expect(page).to have_css('h3', text: "#{subheading} #{contact.full_name}.")
end

Then("there should be a list containing school and placement request data") do
  within(page.find('dl')) do
    expect(page).to have_css('dd', text: @placement_request.school.name)
    expect(page).to have_css('dd', text: @placement_request.availability)
  end
end

Given("my placement request first choice was {string}") do |string|
  expect(@placement_request.subject_first_choice).to eql(string)
end

Then("the subject should be set to {string} by default") do |subject|
  expect(page.find('select').value.to_i).to eql(Bookings::Subject.find_by(name: subject).id)
end

Then("the date should be pre-populated") do
  placement_date = @placement_date.date
  within(page.find('.govuk-date-input')) do
    expect(page.all('input').map(&:value)).to eql(
      [placement_date.day, placement_date.month, placement_date.year].map(&:to_s)
    )
  end
end

Then("the original date should be listed on the page") do
  # this makes sense so the user can refer back to it if they've made changes
  expect(page).to have_css(
    'dd.availability-requested-date',
    text: @placement_date.date.to_formatted_s(:govuk)
  )
end

When("I am on the {string} page for my flexible placement request") do |string|
  step "I am on the '#{string}' page for my chosen placement request"
end

Then("the date fields should be empty") do
  within(page.find('.govuk-date-input')) do
    expect(page.all('input').map(&:value).map(&:presence).compact).to be_empty
  end
end

Given("my school has some placement details") do
  @placement_details = "A long arduous day of shadowing a teacher"
  @school.profile.update(experience_details: @placement_details)
end

Then("the placement details should match the school's placement details") do
  expect(
    page.find(
      'textarea#schools_placement_requests_confirm_booking_placement_details'
    ).value
  ).to eql(@placement_details)
end

Given("I enter three weeks from now as the date") do
  date = 3.weeks.from_now.strftime('%d-%m-%Y')
  step "I fill in the date field 'Confirm experience date' with #{date}"
end

Then("I should see the placement request's duration") do
  expect(page).to have_css('dd', text: "1 day")
end

Then("the future booking date should be listed") do
  expect(page).to have_content(@booking.date.to_formatted_s(:govuk))
end

Given("I am on the {string} page for the placement request") do |string|
  path = path_for(string, placement_request: @placement_request)
  visit(path)
  expect(page.current_path).to eql(path)
end

When("the school has no prior accepted placement requests") do
  # do nothing
end

Then("there should be a list with the following subheadings:") do |table|
  table.raw.transpose.flatten.each do |row|
    expect(page).to have_css('dt', text: row)
  end
end

Then("there should be {string} button") do |string|
  expect(page).to have_css("input[value='#{string}']")
end

Then("there should be a {string} link to the {string} page") do |link, target|
  expect(page).to have_link(
    link,
    href: path_for(target, placement_request: @placement_request)
  )
end

Given("the school has a prior booking") do
  FactoryBot.create(:bookings_booking, :accepted, bookings_school: @school)
end

Then("there should be an {string} button and a {string} link") do |button_text, link_text|
  expect(page).to have_button(button_text)
  expect(page).to have_link(link_text)
end

Then("I should be on the {string} page for the placement request") do |string|
  expect(page.current_path).to eql(path_for(string, placement_request: @placement_request))
  expect(@placement_request.booking).to be_present
end
