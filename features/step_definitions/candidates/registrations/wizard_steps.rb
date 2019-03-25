Given("I'm applying for a school") do
  @school = FactoryBot.create(:bookings_school)
  @school.subjects.create! name: 'Physics'
  @school.subjects.create! name: 'Mathematics'
end

Given("I have completed the placement preference form") do
  visit path_for 'request school experience placement', school: @school
  fill_in 'Is there anything schools need to know about your availability for school experience?', with: 'From Epiphany to Whitsunday'
  fill_in 'What do you want to get out of your school experience?', with: 'I enjoy teaching'
  click_button 'Continue'
end

Given("I have completed the contact information form") do
  visit path_for 'enter your contact details', school: @school
  fill_in 'Full name', with: 'testy mctest'
  fill_in 'Email address', with: 'test@example.com'
  fill_in 'Building', with: 'Test house'
  fill_in 'Street', with: 'Test street'
  fill_in 'Town or city', with: 'Test Town'
  fill_in 'County', with: 'Testshire'
  fill_in 'Postcode', with: 'TE57 1NG'
  fill_in 'UK telephone number', with: '01234567890'
  click_button 'Continue'
end

Given("I have completed the subject preference form") do
  visit path_for 'candidate subjects', school: @school
  choose 'Graduate or postgraduate'
  select 'Physics', from: 'If you have or are studying for a degree, tell us about your degree subject'
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
  visit path_for 'request school experience placement', school: @school
end

Then("the placement preference form should populated with the details I've entered so far") do
  visit path_for 'request school experience placement', school: @school
  expect(find_field(
    'Is there anything schools need to know about your availability for school experience?'
  ).value).to eq 'From Epiphany to Whitsunday'
  expect(find_field('What do you want to get out of your school experience?').value).to eq \
   'I enjoy teaching'
end

Then("the contact information form should populated with the details I've entered so far") do
  visit path_for 'enter your contact details', school: @school
  expect(find_field('Full name').value).to eq 'testy mctest'
  expect(find_field('Email address').value).to eq 'test@example.com'
  expect(find_field('Building').value).to eq 'Test house'
  expect(find_field('Street').value).to eq 'Test street'
  expect(find_field('Town or city').value).to eq 'Test Town'
  expect(find_field('County').value).to eq 'Testshire'
  expect(find_field('Postcode').value).to eq 'TE57 1NG'
  expect(find_field('UK telephone number').value).to eq '01234567890'
end

Then("the subject preference form should populated with the details I've entered so far") do
  visit path_for 'candidate subjects', school: @school
  expect(find_field('Graduate or postgraduate')).to be_checked
  expect(find_field('If you have or are studying for a degree, tell us about your degree subject').value).to eq \
   'Physics'
  expect(find_field('I’ve applied for teacher training')).to be_checked
  expect(find_field('First choice').value).to eq 'Physics'
  expect(find_field('Second choice').value).to eq 'Mathematics'
end

Then("the background check form should populated with the details I've entered so far") do
  visit path_for 'background checks', school: @school
  expect(find_field('Yes')).to be_checked
end
