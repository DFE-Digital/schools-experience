Given "I check {string}" do |string|
  check string
end

Given "I have completed the Candidate Requirements step" do
  steps %(
    Given I am on the 'candidate requirements' page
    And I choose 'Yes - Sometimes' from the 'Do you require candidates to be DBS-checked?' radio buttons
    And I outline our dbs policy
    And I choose 'Yes' from the 'Do you have any requirements for school experience candidates?' radio buttons
    And I provide details
    When I submit the form
  )
end

Given "I have completes the Fees step, choosing only Administration costs" do
  steps %(
    Given I have completed the Candidate Requirements step
    Given I am on the 'fees charged' page
    And I check 'Administration costs'
    When I submit the form
  )
end

Given "I have completes the Fees step, choosing only DBS costs" do
  steps %(
    Given I am on the 'fees charged' page
    And I check 'DBS check costs'
    When I submit the form
  )
end

Given("I have completes the Fees step, choosing only Other costs") do
  steps %(
    Given I am on the 'fees charged' page
    And I check 'Other costs'
    When I submit the form
  )
end

Then "I should see a validation error message" do
  within '.govuk-error-summary' do
    expect(page).to have_content 'There is a problem'
  end
end
