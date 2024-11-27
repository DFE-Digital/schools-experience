Given("I have completed the wizard") do
  visit path_for('enter your personal details', school: @school)
  step "I have filled in my personal information successfully"
  step "I have filled in my contact information successfully"
  step "I have filled in my education details successfully"
  step "I have filled in my teaching preferences successfully"
  step "I have filled in my placement preferences successfully"
  step "I have filled in my availability preferences successfully"
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
  step "I have filled in my placement preferences for fixed dates successfully"
  step "I have filled in my background checks successfully"
end

Given("I have filled in my subject and date information successfully") do
  within(
    page
      .find('dt', text: @wanted_bookings_placement_date.date.to_formatted_s(:govuk))
      .sibling('dd')
  ) do
    choose("All subjects (1 day)")
  end

  click_button 'Continue'

  expect(page).to have_current_path \
    "/candidates/schools/#{@school.urn}/registrations/personal_information/new"
end

Given("I have filled in my personal information successfully") do
  # Submit contact information form successfully
  fill_in 'First name', with: 'testy'
  fill_in 'Last name', with: 'mctest'
  fill_in 'Email address', with: 'unknown@example.com'
  click_button 'Continue'
  expect(page).to have_current_path \
    "/candidates/schools/#{@school.urn}/registrations/contact_information/new", ignore_query: true
end

Given("I have filled in my contact information successfully") do
  # Submit contact information form successfully
  fill_in 'Address line 1', with: 'Test house'
  fill_in 'Address line 2 (optional)', with: 'Test street'
  fill_in 'Town or city (optional)', with: 'Test Town'
  fill_in 'County (optional)', with: 'Testshire'
  fill_in 'Postcode', with: 'TE57 1NG'
  fill_in 'UK telephone number', with: '01234567890'
  click_button 'Continue'
  expect(page).to have_current_path \
    "/candidates/schools/#{@school.urn}/registrations/education/new", ignore_query: true
end

Given("I have filled in my education details successfully") do
  choose 'Graduate or postgraduate'
  fill_in "What subject are you studying?", with: "Physics"
  click_button 'Continue'
  expect(page).to have_current_path \
    "/candidates/schools/#{@school.urn}/registrations/teaching_preference/new", ignore_query: true
end

Given("I have filled in my teaching preferences successfully") do
  choose "I’m very sure and think I’ll apply"
  select 'Physics', from: 'First choice'
  select 'Mathematics', from: 'Second choice'
  click_button 'Continue'
  expect(page).to have_current_path \
    "/candidates/schools/#{@school.urn}/registrations/placement_preference/new", ignore_query: true
end

Given("I have filled in my placement preferences for fixed dates successfully") do
  fill_in 'Enter what you want to get out of your placement', with: 'I enjoy teaching'
  click_button 'Continue'

  expect(page).to have_current_path \
    "/candidates/schools/#{@school.urn}/registrations/background_check/new", ignore_query: true
end

Given("I have filled in my placement preferences successfully") do
  fill_in 'Enter what you want to get out of your placement', with: 'I enjoy teaching'
  click_button 'Continue'

  expect(page).to have_current_path \
    "/candidates/schools/#{@school.urn}/registrations/availability_preference/new", ignore_query: true
end

Given("I have filled in my availability preferences successfully") do
  fill_in 'Enter your availability', with: 'Only from Epiphany to Whitsunday'

  click_button 'Continue'

  expect(page).to have_current_path \
    "/candidates/schools/#{@school.urn}/registrations/background_check/new", ignore_query: true
end

Given("I have filled in my background checks successfully") do
  # Submit registrations/background_check form successfully
  choose 'Yes'
  click_button 'Continue'
  expect(page).to have_current_path \
    "/candidates/schools/#{@school.urn}/registrations/application_preview", ignore_query: true
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
  expect page.to have_current_path(path_for(string, school: @school.urn))
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
