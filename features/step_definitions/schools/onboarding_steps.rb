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

Given "I have completed the Fees step, choosing only Administration costs" do
  steps %(
    Given I have completed the Candidate Requirements step
    Given I am on the 'fees charged' page
    And I choose 'Yes' from the 'Administration costs' radio buttons
    And I choose 'No' from the 'DBS check costs' radio buttons
    And I choose 'No' from the 'Other costs' radio buttons
    When I submit the form
  )
end

Given "I have completed the Fees step, choosing only DBS costs" do
  steps %(
    Given I am on the 'fees charged' page
    And I choose 'Yes' from the 'DBS check costs' radio buttons
    And I choose 'No' from the 'Administration costs' radio buttons
    And I choose 'No' from the 'Other costs' radio buttons
    When I submit the form
  )
end

Given "I have completed the Fees step, choosing only Other costs" do
  steps %(
    Given I am on the 'fees charged' page
    And I choose 'Yes' from the 'Other costs' radio buttons
    And I choose 'No' from the 'Administration costs' radio buttons
    And I choose 'No' from the 'DBS check costs' radio buttons
    When I submit the form
  )
end

Given "I have completed the Other costs step" do
  steps %(
    Given I have entered the following details into the form:
      | Enter the number of pounds.  | 300              |
      | Explain what the fee covers. | Falconry lessons |
      | Explain how the fee is paid. | Gold sovereigns  |
    And I choose 'Daily' from the 'Is this a daily or one-off fee?' radio buttons
    When I submit the form
  )
end

Given "I have completed the Phases step" do
  steps %(
    Given I am on the 'phases' page
    And I check 'Secondary (11 to 16)'
    And I check '16 to 18 years'
    When I submit the form
  )
end

Given "I have completed the Subjects step" do
  steps %(
    Given I am on the 'Subjects' page
    And I check 'Maths'
    When I submit the form
  )
end

Given "I have completed the College subjects step" do
  steps %(
    Given I am on the 'College subjects' page
    And I check 'Maths'
    When I submit the form
  )
end

Given "I have completed the Description step" do
  steps %(
    Given I am on the 'Description' page
    And I enter 'We have a race track' into the 'Tell us about your school. Provide a summary to help candidates choose your school.' text area
    When I submit the form
  )
end

Given "I have completed the Candidate experience details step" do
  steps %(
    Given I am on the 'Candidate experience details' page
    And I check 'Business dress'
    And I check 'Other'
    And I enter 'Must have nice hat' into the 'For example no denim, jeans, shorts, short skirts, trainers' text area
    And I choose 'No' from the 'Do you provide parking for candidates?' radio buttons
    And I enter 'Carpark next door' into the 'Provide details of where candidates can park near your school.' text area
    And I choose 'No' from the 'Do you provide facilities or support for candidates with disabilities or access needs?' radio buttons
    And I enter '8:15 am' into the 'Start time' text area
    And I enter '4:30 pm' into the 'Finish time' text area
    And I choose 'No' from the 'Are your start and finish times flexible?' radio buttons
    When I submit the form
  )
end

Given "I have completed the Availability preference step" do
  steps %(
    Given I am on the 'Availability preference' page
    And I choose "If you're flexible on dates, describe your school experience availability." from the 'Enter school experience availability or fixed dates' radio buttons
    When I submit the form
  )
end

Given "I have completed the Availability description step" do
  steps %(
    Given I am on the 'Availability description' page
    Given I save the page
    And I enter 'Whenever really' into the 'Outline when you offer school experience at your school.' text area
    When I submit the form
  )
end

Given "I have completed the Experience Outline step" do
  steps %(
    Given I am on the 'Experience Outline' page
    And I enter 'A really good one' into the 'What kind of school experience do you offer candidates?' text area
    And I choose 'Yes' from the 'Do you run your own teacher training or have any links to teacher training organisations and providers?' radio buttons
    And I enter 'We run our own training' into the 'Provide details.' text area
    And I enter 'http://example.com' into the 'Enter a web address.' text area
    When I submit the form
  )
end

Given "I have completed the Admin contact step" do
  steps %(
    Given I am on the 'Admin contact' page
    And I enter 'Gary Chalmers' into the 'Full name' text area
    And I enter '01234567890' into the 'UK telephone number' text area
    And I enter 'g.chalmers@springfield.edu' into the 'Email address' text area
    When I submit the form
    Then I should be on the 'Profile' page
  )
end

Then "I should see a validation error message" do
  within '.govuk-error-summary' do
    expect(page).to have_content 'There is a problem'
  end
end

Then "the page should have the following summary list information:" do |table|
  table.raw.to_h.each do |key, value|
    expect(page).to have_text %r{#{key} #{value}}
  end
end

Given "the secondary school phase is availble" do
  FactoryBot.create :bookings_phase, :secondary
end

Given "the college phase is availble" do
  FactoryBot.create :bookings_phase, :college
end

Given "there are some subjects available" do
  FactoryBot.create :bookings_subject, name: 'Maths'
end

Given "A school is returned from DFE sign in" do
  # FIXME change this once we merge in phase2
  FactoryBot.create :bookings_school, urn: 1234567890
end

Given "I have completed the following steps:" do |table|
  table.hashes.each do |row|
    step_name = row['Step name']
    extra     = row['Extra']

    if row['Extra'].present?
      step "I have completed the #{step_name} step, #{extra}"
    else
      step "I have completed the #{step_name} step"
    end
  end
end

And "I complete the candidate experience form with invalid data" do
  steps %(
    Given I check 'Business dress'
    And I check 'Other'
    And I choose 'No' from the 'Do you provide parking for candidates?' radio buttons
    And I enter 'Carpark next door' into the 'Provide details of where candidates can park near your school.' text area
    And I choose 'No' from the 'Do you provide facilities or support for candidates with disabilities or access needs?' radio buttons
    And I enter '8:15 am' into the 'Start time' text area
    And I enter '4:30 pm' into the 'Finish time' text area
    And I choose 'No' from the 'Are your start and finish times flexible?' radio buttons
  )
end

And "I complete the candidate experience form with valid data" do
  steps %(
    Given I check 'Business dress'
    And I check 'Other'
    And I enter 'Must have nice hat' into the 'For example no denim, jeans, shorts, short skirts, trainers' text area
    And I choose 'No' from the 'Do you provide parking for candidates?' radio buttons
    And I enter 'Carpark next door' into the 'Provide details of where candidates can park near your school.' text area
    And I choose 'No' from the 'Do you provide facilities or support for candidates with disabilities or access needs?' radio buttons
    And I enter '8:15 am' into the 'Start time' text area
    And I enter '4:30 pm' into the 'Finish time' text area
    And I choose 'No' from the 'Are your start and finish times flexible?' radio buttons
  )
end
