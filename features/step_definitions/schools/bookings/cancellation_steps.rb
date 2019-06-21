When("I am on the cancel booking page") do
  path = path_for('cancel booking', booking_id: @booking_id)
  visit(path)
  expect(page.current_path).to eql(path)
end

Given("I have progressed to the cancellation email preview page") do
  steps %(
    Given there is at least one booking
    And I am on the cancel booking page
    And I have entered a reason in the cancellation reasons text area
    And I have entered a extra details in the extra details text area
    When I click the 'Preview cancellation email' button
    Then I should see a preview of what I have entered
  )
end

Then("I should see a {string} confirmation") do |string|
  expect(page).to have_css(
    '.govuk-panel.govuk-panel--confirmation',
    text: string
  )
end
