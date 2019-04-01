Given "I check {string}" do |string|
  check string
end

Given "I have completed the Candidate Requirements step" do
  steps %Q(
    Given I am on the 'candidate requirements' page
    And I choose 'Yes - Sometimes' from the 'Do you require candidates to be DBS-checked?' radio buttons
    And I outline our dbs policy
    And I choose 'Yes' from the 'Do you have any requirements for school experience candidates?' radio buttons
    And I provide details
    When I submit the form
  )
end

Given "I have completes the Fees step, choosing only Administration costs" do
  steps %Q(
    Given I have completed the Candidate Requirements step
    Given I am on the 'fees charged' page
    And I check 'Administration costs'
    When I submit the form
  )
end

Given "I have completes the Fees step, choosing only DBS costs" do
  steps %Q(
    Given I am on the 'fees charged' page
    And I check 'DBS check costs'
    When I submit the form
  )
end

Given "I have completes the Fees step, choosing only Other costs" do
  steps %Q(
    Given I am on the 'fees charged' page
    And I check 'Other costs'
    When I submit the form
  )
end

Given "I have completed the Other costs step" do
  steps %Q(
    Given I have entered the following details into the form:
      | Enter the number of pounds.  | 300              |
      | Explain what the fee covers. | Falconry lessons |
      | Explain how the fee is paid. | Gold sovereigns  |
    And I choose 'Daily' from the 'Is this a daily or one-off fee?' radio buttons
    When I submit the form
  )
end

Given "I have complete the Phases step" do
  steps %Q(
    Given I am on the 'phases' page
    And I check 'Secondary'
    And I check '16 to 18 years'
    When I submit the form
  )
end

Given "I have complete the Secondary subjects step" do
  steps %Q(
    Given I am on the 'Secondary subjects' page
    And I check 'Maths'
    When I submit the form
  )
end

Then "I should see a validation error message" do
  within '.govuk-error-summary' do
    expect(page).to have_content 'There is a problem'
  end
end

Given "The secondary school phase is availble" do
  FactoryBot.create :bookings_phase, :secondary
end

Given "The college phase is availble" do
  FactoryBot.create :bookings_phase, :college
end

Given "There are some subjects available" do
  FactoryBot.create :bookings_subject, name: 'Maths'
end
