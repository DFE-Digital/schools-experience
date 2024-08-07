Given("I'm applying for a school") do
  @school = FactoryBot.create(:bookings_school)
  @school.subjects.create! name: 'Physics'
  @school.subjects.create! name: 'Mathematics'
end

Given("I have completed the placement preference form") do
  visit path_for 'placement preference', school: @school
  fill_in 'Enter what you want to get out of your placement', with: 'I enjoy teaching'
  click_button 'Continue'
end

Given("I have completed the availability preference form") do
  visit path_for 'availability preference', school: @school
  fill_in 'Enter your availability', with: 'From Epiphany to Whitsunday'
  click_button 'Continue'
end

Given("I have completed the personal information form") do
  visit path_for 'enter your personal details', school: @school
  fill_in 'First name', with: 'testy'
  fill_in 'Last name', with: 'mctest'
  fill_in 'Email address', with: 'test@example.com'
  click_button 'Continue'
end

Given("I have completed the contact information form") do
  visit path_for 'enter your contact details', school: @school
  fill_in 'Address line 1', with: 'Test house'
  fill_in 'Address line 2 (optional)', with: 'Test street'
  fill_in 'Town or city (optional)', with: 'Test Town'
  fill_in 'County (optional)', with: 'Testshire'
  fill_in 'Postcode', with: 'TE57 1NG'
  fill_in 'UK telephone number', with: '01234567890'
  click_button 'Continue'
end

Given("I have completed the education form") do
  visit path_for 'education', school: @school
  choose 'Graduate or postgraduate'

  subject_field = find_field("What subject are you studying?")
  subject_field.fill_in(with: "Physics")

  unless subject_field.native.is_a?(Nokogiri::XML::Element)
    # Unless we are using the standard rack-test driver (which does not support
    # javascript), we need to change the focus off the control before continuing
    subject_field.send_keys :tab
  end

  click_button 'Continue'
end

Given("I have completed the teaching preference form") do
  visit path_for 'teaching preference', school: @school
  choose 'I’ve applied for teacher training'
  select 'Physics', from: 'First choice'
  select 'Mathematics', from: 'Second choice'
  click_button 'Continue'
end

Given("I have completed the background check form") do
  visit path_for 'background checks', school: @school
  choose 'Yes'
  click_button 'Continue'
end

Given("I have navigated away from the wizard") do
  visit '/'
end

When("I come back to the wizard") do
  visit path_for 'placement preference', school: @school
end

Then("the availability preference form should populated with the details I've entered so far") do
  visit path_for 'placement preference', school: @school
  expect(find_field('Enter what you want to get out of your placement').value).to eq 'I enjoy teaching'
end

Then("the placement preference form should populated with the details I've entered so far") do
  visit path_for 'availability preference', school: @school
  expect(find_field(
    'Enter your availability'
  ).value).to eq 'From Epiphany to Whitsunday'
end

Then("the personal information form should populated with the details I've entered so far") do
  visit path_for 'enter your personal details', school: @school
  expect(find_field('First name').value).to eq 'testy'
  expect(find_field('Last name').value).to eq 'mctest'
  expect(find_field('Email address').value).to eq 'test@example.com'
end

Then("the contact information form should populated with the details I've entered so far") do
  visit path_for 'enter your contact details', school: @school
  expect(find_field('Address line 1').value).to eq 'Test house'
  expect(find_field('Address line 2 (optional)').value).to eq 'Test street'
  expect(find_field('Town or city (optional)').value).to eq 'Test Town'
  expect(find_field('County (optional)').value).to eq 'Testshire'
  expect(find_field('Postcode').value).to eq 'TE57 1NG'
  expect(find_field('UK telephone number').value).to eq '01234567890'
end

Then("the education form should populated with the details I've entered so far") do
  visit path_for 'education', school: @school
  expect(find_field('Graduate or postgraduate')).to be_checked
  expect(find_field('What subject are you studying?').value).to eq 'Physics'
end

Then("the teaching preference form should populated with the details I've entered so far") do
  visit path_for 'teaching preference', school: @school
  expect(find_field("I’ve applied for teacher training")).to be_checked
  expect(find_field('First choice').value).to eq 'Physics'
  expect(find_field('Second choice').value).to eq 'Mathematics'
end

Then("the background check form should populated with the details I've entered so far") do
  visit path_for 'background checks', school: @school
  expect(find_field('Yes')).to be_checked
end
