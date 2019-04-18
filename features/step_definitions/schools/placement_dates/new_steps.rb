Given("I fill in the form with a future date and duration of {int}") do |int|
  @date = 1.week.from_now
  @duration = int
  step "I fill in the date field 'Enter a start date' with #{@date.strftime('%d-%m-%Y')}"
  fill_in "How many days will it last?", with: @duration
end

Then("my newly-created placement date should be listed") do
  within('#placement-dates .placement-date') do
    expect(page).to have_css('th', text: @date.to_date.to_formatted_s(:govuk))
    expect(page).to have_css('td', text: "#{@duration} days")
  end
end
