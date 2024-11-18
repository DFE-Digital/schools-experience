Given "I have entered a placement date" do
  steps %(
    Given I am on the 'new placement date' page
    And I fill in the form with a future date
    And I select not recurring
    And I submit the form
  )
end

Given "I have entered a recurring placement date" do
  steps %(
    Given I am on the 'new placement date' page
    And I fill in the form with a future date
    And I select recurring
    And I submit the form
  )
end

Given("I fill in the placement details form with a duration of {int}") do |int|
  @duration = int
  fill_in "How long will it last?", with: @duration
  choose "In school experience"
end

Given "I have entered placement details" do
  steps %(
    Given I fill in the placement details form with a duration of 3
    And I submit the form
  )
end

Given "I have entered a secondary placement date for a multi-phase school" do
  secondary_label = "Secondary including secondary schools"

  steps %(
    Given I fill in the placement details form with a duration of 3
    And I choose '#{secondary_label}' from the 'Select school experience phase' radio buttons
    And I submit the form
  )
end

Given "the placement date is subject specific" do
  steps %(
    Given I choose 'No' from the "Is there a maximum number of bookings you’ll accept for this date?" radio buttons
    And I choose 'Specific to a subject' from the "Select type of experience" radio buttons
    And I submit the form
  )
end

Given "the placement date is not subject specific" do
  steps %(
    Given I choose 'No' from the "Is there a maximum number of bookings you’ll accept for this date?" radio buttons
    And I choose 'General experience' from the "Select type of experience" radio buttons
    And I submit the form
  )
end

Given "I have previously selected {string}" do |subject_name|
  all("input[type='checkbox']").each { |checkbox| checkbox.set(false) }

  check(subject_name)
  click_button('Continue')
  click_button('Publish placement date')

  expect(page.current_path).to eql(path_for('placement dates'))
  expect(page).to have_content(subject_name)
end

Given("I uncheck all dates") do
  page.all("input[type=checkbox]").find_each(&:uncheck)
end

When "I select {string} recurrence and enter a valid date" do |recurrence_type|
  placement_date = Bookings::PlacementDate.last.date
  valid_date = placement_date + 3.months

  steps %(
    Given I choose "#{recurrence_type}" from the "How often do you want this event to recur?" radio buttons
    And I fill in the date field "Enter last date of the recurrence" with #{valid_date.strftime('%d-%m-%Y')}
  )

  step "I check to recur on days 'Monday, Wednesday, Friday'" if recurrence_type == "Custom"
end

Then "I should see the {string} recurring dates" do |recurrence_type|
  placement_date = Bookings::PlacementDate.last.date
  placement_date_weekday = placement_date.strftime("%A").downcase
  recurring_dates = page.all("input[type=checkbox]").map { |c| c[:value].to_date }
  all_weekdays = (placement_date..(placement_date + 3.months)).reject(&:on_weekend?).to_a

  case recurrence_type
  when "Daily"
    expect(recurring_dates).to eq(all_weekdays)
  when "Weekly"
    weekly_dates = all_weekdays.select { |d| d.send("#{placement_date_weekday}?") }
    expect(recurring_dates).to eq(weekly_dates)
  when "Fortnightly"
    fortnightly_dates = all_weekdays
      .select { |d| d.send("#{placement_date_weekday}?") }
      .select.with_index { |_, i| i.even? }

    expect(recurring_dates).to eq(fortnightly_dates)
  when "Custom"
    custom_dates = all_weekdays
      .select { |d| d.monday? || d.wednesday? || d.friday? }

    expect(recurring_dates).to eq(custom_dates)
  else
    raise ArgumentError, "Recurrence type not recognised: #{recurrence_type}"
  end
end

When "I try to edit the subjects for my newly-created placement date" do
  path = path_for('new subject selection', placement_date_id: Bookings::PlacementDate.last.id)
  visit path
  expect(page.current_path).to eql(path)
end

Then "I should see the date summary row" do
  placement_date = @school.bookings_placement_dates.last.date
  expect(page).to have_css("dt.govuk-summary-list__key", text: "Date")
  expect(page).to have_css("dd.govuk-summary-list__value", text: placement_date.to_formatted_s(:govuk))
end

Then "I check to recur on days {string}" do |days|
  days.split(", ").each { |day| check day }
end

Then("all recurring dates should be checked") do
  checked_states = page.all("input[type=checkbox]").map(&:checked?)
  checked_states.each { |state| expect(state).to be_truthy }
end

Then("the {string} checkbox should be checked") do |subject_name|
  expect(get_input(page, subject_name)).to be_checked
end

Then("the {string} checkbox should not be checked") do |subject_name|
  expect(get_input(page, subject_name)).not_to be_checked
end

Then "there should be a {string} number field" do |string|
  expect(page).to have_field(string, type: 'number')
end

Then("I should be on the {string} page for my placement date") do |page_name|
  expect(page.current_path).to eql(path_for(page_name, placement_date_id: @school.bookings_placement_dates.last.id))
end

Then "I should be on the new configuration page for this date" do
  expect(page.current_path).to eq \
    path_for('new configuration', placement_date_id: @school.bookings_placement_dates.last.id)
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

Then("there should be no subject specificity option") do
  expect(page).not_to have_text('Is this date available for all the subjects you offer?')
end

Then("there should be a subject specificity option") do
  expect(page).not_to have_css('label', text: 'Is this date available for all the subjects you offer?')
end
