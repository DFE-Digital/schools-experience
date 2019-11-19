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

Given("I change device") do
  Capybara.reset_session!
end

Given "there are no registration sessions" do
  # We need to do this so when we fetch out the session key in the next step
  # it's always the key we expect as there's only going to be one
  # this will probably break parralel tests
  Redis.current.keys("test:registrations*").each(&Redis.current.method(:del))
end

Given("I follow the verify link in the confirmation email") do
  # this will probably break parralel tests
  session_key = Redis.current.keys('test:registrations:*').last
  uuid = JSON.parse(Redis.current.get(session_key)).fetch('uuid')

  visit path_for('verify your email with token',
    school: @school, session_token: @session_token, uuid: uuid)
end

# TODO SE-1992 Remove this
Given("I follow the legacy verify link in the confirmation email") do
  visit "/candidates/verify/#{@school.to_param}/#{@session_token.to_param}"
end

Given "I have chosen a subject specific date" do
  steps %(
    And I am on the 'choose a subject and date' screen for my chosen school
    And I have filled in my subject and date information successfully
    And I submit the form
  )
end

Given "I should not have been kicked back to the start of the wizard" do
  expect(page.current_path).not_to match(/subject_and_date_information/)
end
