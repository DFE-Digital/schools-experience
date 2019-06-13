Given("I fill in the form with a future date and duration of {int}") do |int|
  @date = 1.week.from_now
  @duration = int
  step "I fill in the date field 'Enter a start date' with #{@date.strftime('%d-%m-%Y')}"
  fill_in "How many days will it last?", with: @duration
end

Given("I fill in the form with a duration of {int}") do |int|
  @duration = int
  fill_in "How many days will it last?", with: @duration
end

Then("my newly-created placement date should be listed") do
  within('#placement-dates .placement-date') do
    expect(page).to have_css('td', text: "#{@duration} days")
  end
end


Given("I fill in the date field with an invalid date of 31st September next year") do
  year = Date.today.year + 1
  step "I fill in the date field 'Enter a start date' with 31-09-#{year}"
end
