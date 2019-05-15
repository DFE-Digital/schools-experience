Given("I have completed the wizard") do
  visit path_for('enter your personal details', school: @school)
  step "I have filled in my personal information successfully"
  step "I have filled in my contact information successfully"
  step "I have filled in my subject preferences successfully"
  step "I have filled in my placement preferences successfully"
  step "I have filled in my background checks successfully"
end

Given("I have filled in my personal information successfully") do
  # Submit contact information form successfully
  fill_in 'First name', with: 'testy'
  fill_in 'Last name', with: 'mctest'
  fill_in 'Email address', with: 'test@example.com'
  fill_in 'Day', with: '01'
  fill_in 'Month', with: '01'
  fill_in 'Year', with: '2000'
  click_button 'Continue'
  expect(page.current_path).to eq \
    "/candidates/schools/#{@school.urn}/registrations/contact_information/new"
end

Given("I have filled in my contact information successfully") do
  # Submit contact information form successfully
  fill_in 'Building', with: 'Test house'
  fill_in 'Street', with: 'Test street'
  fill_in 'Town or city', with: 'Test Town'
  fill_in 'County', with: 'Testshire'
  fill_in 'Postcode', with: 'TE57 1NG'
  fill_in 'UK telephone number', with: '01234567890'
  click_button 'Continue'
  expect(page.current_path).to eq \
    "/candidates/schools/#{@school.urn}/registrations/subject_preference/new"
end

Given("I have filled in my subject preferences successfully") do
  # Submit registrations/subject_preference form successfully
  choose 'Graduate or postgraduate'
  select 'Physics', from: 'If you have or are studying for a degree, tell us about your degree subject'
  choose "I’m very sure and think I’ll apply"
  select 'Physics', from: 'First choice'
  click_button 'Continue'
  expect(page.current_path).to eq \
    "/candidates/schools/#{@school.urn}/registrations/placement_preference/new"
end

Given("I have filled in my placement preferences successfully") do
  # Submit registrations/placement_preference form successfully
  if @fixed_dates
    choose @wanted_bookings_placement_date
  else
    fill_in 'Is there anything schools need to know about your availability for school experience?', with: 'Only free from Epiphany to Whitsunday'
  end
  fill_in 'What do you want to get out of your school experience?', with: 'I enjoy teaching'
  click_button 'Continue'

  expect(page.current_path).to eq \
    "/candidates/schools/#{@school.urn}/registrations/background_check/new"
end

Given("I have filled in my background checks successfully") do
  # Submit registrations/background_check form successfully
  choose 'Yes'
  click_button 'Continue'
  expect(page.current_path).to eq \
    "/candidates/schools/#{@school.urn}/registrations/application_preview"
end

Given("my school has flexible dates") do
  @fixed_dates = false
  # do nothing, it's the default
end

Given("my school has fixed dates") do
  @fixed_dates = true
  @school.update_attributes(availability_preference_fixed: true)
  (1..3).each { |i| i.weeks.from_now }.each do |date|
    @school.bookings_placement_dates.create(date: date.weeks.from_now)
    @wanted_bookings_placement_date = @school.bookings_placement_dates.last.to_s
  end
  # do nothing, it's the default
end

Given("my school of choice exists") do
  @school = FactoryBot.create(:bookings_school, urn: 123456)
end

Given("my school of choice offers {string}") do |string|
  string.split(", ").each do |subject_name|
    @school.subjects << FactoryBot.create(:bookings_subject, name: subject_name)
  end
end

Given("My school offers physics") do
  @school.subjects << FactoryBot.create(:bookings_subject, name: "Physics")
end

When("I am on the {string} page for my choice of school") do |string|
  expect(page.current_path).to eql(path_for(string, school: @school.urn))
end

Then("I should see the following summary rows:") do |table|
  table.hashes.each do |row|
    within(".#{row['Heading'].tr(' ', '-').downcase}") do
      expect(page).to have_css('dd', text: row['Value'])
      if row['Change link path'].present?
        expect(page).to have_link('Change', href: /#{row['Change link path']}/)
      end
    end
  end
end

Then("I should see a summary row containing my selected date") do
  within(".placement-date") do
    expect(page).to have_content(@wanted_bookings_placement_date)
  end
end

Then("the row should have a {string} link to {string}") do |link_text, path|
  within(".placement-date") do
    expect(page).to have_link(link_text, href: /#{path}/)
  end
end
