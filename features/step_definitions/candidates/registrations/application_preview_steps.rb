Given("I have completed the wizard") do
  visit path_for('enter your personal details', school: @school)
  step "I have filled in my personal information successfully"
  step "I have filled in my contact information successfully"
  step "I have filled in my education details successfully"
  step "I have filled in my teaching preferences successfully"
  step "I have filled in my placement preferences successfully"
  step "I have filled in my background checks successfully"
end

Given("I have completed the wizard for a fixed date school") do
  @school.update(availability_preference_fixed: true)
  @wanted_bookings_placement_date = @school.bookings_placement_dates.create!(
    date: 2.weeks.from_now, published_at: 1.week.ago, supports_subjects: true, virtual: false
  )

  visit path_for('choose a subject and date', school: @school)

  step "I have filled in my subject and date information successfully"
  step "I have filled in my personal information successfully"
  step "I have filled in my contact information successfully"
  step "I have filled in my education details successfully"
  step "I have filled in my teaching preferences successfully"
  step "I have filled in my placement preferences successfully"
  step "I have filled in my background checks successfully"
end

Given("I have filled in my subject and date information successfully") do
  within(
    page
      .find('dt', text: @wanted_bookings_placement_date.date.strftime("%d %B %Y"))
      .sibling('dd')
  ) do
    choose("All subjects (1 day)")
  end

  click_button 'Continue'

  expect(page.current_path).to eql \
    "/candidates/schools/#{@school.urn}/registrations/personal_information/new"
end

Given("I have filled in my personal information successfully") do
  # Submit contact information form successfully
  fill_in 'First name', with: 'testy'
  fill_in 'Last name', with: 'mctest'
  fill_in 'Email address', with: 'unknown@example.com'
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
    "/candidates/schools/#{@school.urn}/registrations/education/new"
end

Given("I have filled in my education details successfully") do
  choose 'Graduate or postgraduate'
  select 'Physics', from: 'If you have or are studying for a degree, tell us about your degree subject'
  click_button 'Continue'
  expect(page.current_path).to eq \
    "/candidates/schools/#{@school.urn}/registrations/teaching_preference/new"
end

Given("I have filled in my teaching preferences successfully") do
  choose "I’m very sure and think I’ll apply"
  select 'Physics', from: 'First choice'
  select 'Mathematics', from: 'Second choice'
  click_button 'Continue'
  expect(page.current_path).to eq \
    "/candidates/schools/#{@school.urn}/registrations/placement_preference/new"
end

Given("I have filled in my placement preferences successfully") do
  unless @fixed_dates
    fill_in 'Tell us about your availability', with: 'Only free from Epiphany to Whitsunday'
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

Given("the/my school has fixed dates") do
  @fixed_dates = true
  @school.update(availability_preference_fixed: true)
  (1..3).each { |i| i.weeks.from_now }.each do |date|
    @school.bookings_placement_dates.create(date: date.weeks.from_now, published_at: 1.week.ago, virtual: false)
    @wanted_bookings_placement_date = @school.bookings_placement_dates.last
  end
  # do nothing, it's the default
end

When("I am on the {string} page for my choice of school") do |string|
  expect(page.current_path).to eql(path_for(string, school: @school.urn))
end

Then("I should see the following summary rows:") do |table|
  table.hashes.each do |row|
    heading_selector = row['Heading'].tr(' ', '-').downcase

    row_selector = if page.has_selector? ".#{heading_selector}"
                     ".#{heading_selector}"
                   else
                     "##{heading_selector}"
                   end

    within row_selector do
      expect(page).to have_css('dd', text: row['Value'])
      if row['Change link path'].present?
        expect(page).to have_link('Change', href: /#{row['Change link path']}/)
      end
    end
  end
end

Then("I should see a summary row containing my selected date") do
  within(".start-date-and-subject") do
    expect(page).to have_content(@wanted_bookings_placement_date.to_s)
  end
end

Then("the row should have a {string} link to {string}") do |link_text, path|
  within(".start-date-and-subject") do
    expect(page).to have_link(link_text, href: /#{path}/)
  end
end
