Given("I check {string}") do |string|
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
