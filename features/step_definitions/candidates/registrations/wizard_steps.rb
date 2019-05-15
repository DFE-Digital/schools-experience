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
  ).value).to eq 'Only free from Epiphany to Whitsunday'
  expect(find_field('What do you want to get out of your school experience?').value).to eq 'I enjoy teaching'
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
  expect(find_field('If you have or are studying for a degree, tell us about your degree subject').value).to eq 'Physics'
  expect(find_field("I’m very sure and think I’ll apply")).to be_checked
  expect(find_field('First choice').value).to eq 'Physics'
  expect(find_field('Second choice').value).to eq 'Mathematics'
end

Then("the background check form should populated with the details I've entered so far") do
  visit path_for 'background checks', school: @school
  expect(find_field('Yes')).to be_checked
end
