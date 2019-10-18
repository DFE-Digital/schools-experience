Given("the school has some primary placement dates set up") do
  @primary_dates = FactoryBot.create_list(
    :bookings_placement_date,
    3,
    bookings_school: @school,
    supports_subjects: false
  )
end

When("I am on the {string} screen for my chosen school") do |page_name|
  path = path_for(page_name, school: @school)
  visit(path)
  expect(page.current_path).to eql(path)
end

Then("I should see the list of primary placement dates") do
  expect(page).to have_css('h3', text: 'Primary placement dates')

  @primary_dates.each do |pd|
    expect(page).to have_css(
      'label',
      text: "#{pd.date.strftime('%d %B %Y')} (#{pd.duration} day)".downcase
    )
  end
end

Given("the school has some secondary placement dates set up") do
  @secondary_dates = FactoryBot.create_list(
    :bookings_placement_date,
    3,
    bookings_school: @school,
    supports_subjects: true
  )
end

Then("I should see the list of secondary placement dates") do
  @secondary_dates.each do |sd|
    expect(page).to have_css('dt', text: sd.date.strftime('%d %B %Y'))

    sd.subjects.each do |subject|
      expect(page).to have_css('label', text: subject.name)
    end
  end
end

Given("the school has both primary and secondary dates set up") do
  steps %(
    And the school has some primary placement dates set up
    And the school has some secondary placement dates set up
  )
end

Given("the school has a secondary date with Maths set up") do
  @maths = FactoryBot.create(:bookings_subject, name: 'Maths')
  @school.subjects << @maths
  @secondary_date = FactoryBot.build(
    :bookings_placement_date,
    bookings_school: @school,
    supports_subjects: true,
    subject_specific: true
  )

  @secondary_date.subjects << @maths
  @secondary_date.save
end

When("I select the first secondary date") do
  choose "Maths"
end

Then("I should be on the {string} page for my chosen school") do |string|
  path = path_for(string, school: @school)
  expect(page.current_path).to eql(path)
end

Then("I should see the duration listed in each radio button label") do
  page.all('label').each do |label|
    expect(label.text).to end_with("(1 day)")
  end
end

When("I make no selection") do
  # do nothing
end

Then("I should see an error and the date and subject options should be marked as being incorrect") do
  expect(page).to have_css('.govuk-error-summary', text: /there is a problem/i)
  expect(page).to have_css('.subject-and-date-selection--error')
end
