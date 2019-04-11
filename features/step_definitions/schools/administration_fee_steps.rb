Given("I have completes the Fees step, choosing only Administration costs") do
  steps %(
    Given I have completed the Candidate Requirements step
    Given I am on the 'fees charged' page
    And I check 'Administration costs'
    When I submit the form
  )
end

Then("I should see a validation error message") do
  within '.govuk-error-summary' do
    expect(page).to have_content 'There is a problem'
  end
end
