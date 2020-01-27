Given("I fill in the form with a future date and duration of {int}") do |int|
  @date = 1.week.from_now
  @duration = int
  step "I fill in the date field 'Enter start date' with #{@date.strftime('%d-%m-%Y')}"
  fill_in "How long will it last?", with: @duration
end

Given("I fill in the form with a duration of {int}") do |int|
  @duration = int
  fill_in "How long will it last?", with: @duration
end

Then("my newly-created placement date should be listed") do
  within('#placement-dates .placement-date') do
    expect(page).to have_css('td', text: "#{@duration} days")
  end
end

Given("I fill in the {string} date field with an invalid date of 31st September next year") do |label|
  year = Date.today.year + 1
  step "I fill in the date field '#{label}' with 31-09-#{year}"
end

Then "I should be on the new subject specific page for this date" do
  expect(page.current_path).to eq path_for 'new subject specific', placement_date_id: Bookings::PlacementDate.last.id
end
