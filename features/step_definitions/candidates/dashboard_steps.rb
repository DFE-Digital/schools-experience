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
