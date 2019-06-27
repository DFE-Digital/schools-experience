Given("I visit the Dashboard page") do
  visit candidates_dashboard_path
end

Then("I should be redirected to the candidate signin page") do
  expect(page.current_path).to eql(candidates_signin_path)
end

Given("I am on the candidate signin page") do
  visit candidates_dashboard_path
  expect(page.current_path).to eql(candidates_signin_path)
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

When("I am on the Verify Link Sent page") do
  expect(page.body).to match(/Confirm your email/)
end

When("I follow the sign in link from the email") do
  token = Candidates::SessionToken.reorder(:id).last
  visit candidates_signin_confirmation_path(token)
end

Then("I will see the Dashboard page") do
  expect(page.current_path).to eql(candidates_dashboard_path)
end

Given("I use an expired signin link") do
  @token = FactoryBot.create(:candidate_session_token, :auto_expired)
  visit candidates_signin_confirmation_path(@token)
end

Then("I will see the link expired page") do
  expect(page.current_path).to eql(candidates_signin_confirmation_path(@token))
  expect(page.body).to match(/Sign in link has expired/)
end
