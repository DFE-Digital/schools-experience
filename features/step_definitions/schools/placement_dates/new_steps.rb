Given("I fill in the form with a future date") do
  @date = 1.week.from_now
  step "I fill in the date field 'Enter placement start date' with #{@date.strftime('%d-%m-%Y')}"
end

Given("I select not recurring") do
  step "I choose 'No' from the 'Is this a recurring event?' radio buttons"
end

Given("I fill in the {string} date field with an invalid date of 31st September next year") do |label|
  year = 1.year.from_now.year
  step "I fill in the date field '#{label}' with 31-09-#{year}"
end

Then("my newly-created placement date should be listed") do
  within('#placement-dates .placement-date') do
    expect(page).to have_css('td', text: "#{@duration} days")
  end
end
