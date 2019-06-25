Given("I have completed the Personal Information step for my school of choice") do
  visit path_for('enter your personal details', school: @school)
  fill_in 'First name', with: 'testy'
  fill_in 'Last name', with: 'mctest'
  fill_in 'Email address', with: 'test@example.com'
  fill_in 'Day', with: '1'
  fill_in 'Month', with: '1'
  fill_in 'Year', with: '1980'
  click_button 'Continue'
end

Then("I should see an email was sent to my email address") do
  within('#main-content') do
    expect(page).to have_css('li', text: 'test@example.com')
  end
end

Given("I have a valid session token") do
  @session_token = FactoryBot.create(:candidate_session_token)
end

Given("I follow the verify link in the confirmation email") do
  visit path_for('verify your email with token',
    school: @school, session_token: @session_token)
end
