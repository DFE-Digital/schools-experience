Given "I have entered a placement date" do
  steps %(
    Given I am on the 'new placement date' page
    And I fill in the form with a future date and duration of 3
    And I choose 'No limit' from the 'Is there a limit on the number of spaces' radio buttons
    And I submit the form
  )
end

Given "I have entered a secondary placement date for a multi-phase school" do
  secondary_label = "Secondary including secondary schools"

  steps %(
    Given I am on the 'new placement date' page
    And I fill in the form with a future date and duration of 3
    And I choose 'No limit' from the 'Is there a limit on the number of spaces' radio buttons
    And I choose '#{secondary_label}' from the 'Select school experience phase' radio buttons
    And I submit the form
  )
end

Given "the placement date is subject specific" do
  steps %(
    Given I choose 'Specific to a subject' from the "Select type of experience" radio buttons
    And I submit the form
  )
end

Given "I have previously selected {string}" do |subject_name|
  # pick biology from the subjects list and continue
  check(subject_name)
  click_button('Continue')

  expect(page.current_path).to eql(path_for('placement dates'))
  expect(page).to have_content(subject_name)
end

When "I try to edit the subjects for my newly-created placement date" do
  path = path_for('new subject selection', placement_date_id: Bookings::PlacementDate.last.id)
  visit path
  expect(page.current_path).to eql(path)
end

Then("the {string} checkbox should be checked") do |subject_name|
  expect(get_input(page, subject_name)).to be_checked
end

Then "the page's main heading should be the date I just entered" do
  date = @school.bookings_placement_dates.last
  expected_title = "#{date.date.to_formatted_s(:govuk)} (#{date.duration} days)"
  expect(page).to have_css 'h1', text: expected_title
end

Then "there should be a {string} number field" do |string|
  expect(page).to have_field(string, type: 'number')
end

Then "I should be on the new subject selection page for this date" do
  expect(page.current_path).to eq \
    path_for('new subject selection', placement_date_id: @school.bookings_placement_dates.last.id)
end

Then "I should see a list of subjects the school offers" do
  @school.subjects.each do |subject|
    expect(page).to have_field(subject.name, type: 'checkbox')
  end
end

Then "my date should be listed" do
  date = @school.bookings_placement_dates.last

  expect(page).to have_text date.date.to_formatted_s(:govuk)
  expect(page).to have_text("#{date.duration} " + 'day'.pluralize(date.duration))
  expect(page).to have_text date.date.to_formatted_s(:govuk)

  if date.subjects == @school.subjects
    expect(page).to have_text 'All subjects'
  else
    date.subjects.map(&:name).each { |name| expect(page).to have_text name }
  end
end

Then("I should be on the new subject specific page for my placement date") do
  pd = Bookings::PlacementDate.last
  expect(page.current_path).to eql path_for('new subject specific', placement_date_id: pd.id)
end

Then("there should be no subject specificity option") do
  expect(page).not_to have_text('Is this date available for all the subjects you offer?')
end

Then("there should be a subject specificity option") do
  expect(page).not_to have_css('label', text: 'Is this date available for all the subjects you offer?')
end
