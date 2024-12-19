Given("I am logged in as a candidate user") do
  gitis_contact = FactoryBot.build(:api_schools_experience_sign_up_with_name)
  @current_candidate = FactoryBot.create(:candidate, :confirmed, gitis_uuid: gitis_contact.candidate_id, gitis_contact: gitis_contact, created_in_gitis: true)

  allow_any_instance_of(Candidates::DashboardBaseController).to receive(:current_contact).and_return(gitis_contact)
  allow(Bookings::Candidate).to receive(:find_by_gitis_contact).and_return(@current_candidate)
end

Given("I visit the Dashboard page") do
  visit candidates_dashboard_path
end

Then("I should be redirected to the candidate signin page") do
  expect(page).to have_current_path(candidates_signin_path)
end

Given("I am on the candidate signin page") do
  visit candidates_dashboard_path
  expect(page).to have_current_path(candidates_signin_path)
end

When("I enter my name and email address") do
  fill_in 'Email address', with: "testy@mctest.com"
  fill_in 'First name', with: "Testy"
  fill_in 'Last name', with: "McTest"
  fill_in 'Day', with: '01'
  fill_in 'Month', with: '01'
  fill_in 'Year', with: '1980'
end

When("I click the '{string}' button") do |button_label|
  click_button button_label
end

Then("I will see the Verification Code page") do
  expect(page).to have_text("We’ve emailed a verification code to")
end

Then('there should be a status notification for missing dates') do
  within('#profile-status') do
    expect(page).to have_content('Your profile is currently on, but your school will not appear in candidate searches')
  end
end

Then('there should be a status notification for missing availability') do
  within('#profile-status') do
    expect(page).to have_content('You have no upcoming placement dates or information about availability. Your profile will not appear in candidate searches.')
  end
end

Given('there is a fully-onboarded school') do
  @school ||= FactoryBot.create(:bookings_school, :onboarded, urn: 123_456)
end

Given('there are some placement requests of the current user') do
  @placement_requests = FactoryBot.create_list(:placement_request, 3, candidate: @current_candidate, school: @school)
end

Then('I should see all my placement requests listed') do
  within("#placement-requests") do
    expect(page).to have_css('.placement-request', count: @current_candidate.placement_requests.count)
  end
end
