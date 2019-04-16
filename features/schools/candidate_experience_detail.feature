Feature: Candidate experience details
  So canidates know our requirements
  As a school administrator
  I want to specify our requirements for candidates

  Background: I have completed the wizard thus far
    Given I am logged in as a DfE user
    Given The secondary school phase is availble
    Given The college phase is availble
    And There are some subjects available
    And I have completed the Candidate Requirements step
    And I have completed the Fees step, choosing only Other costs
    And I have completed the Other costs step
    And I have completed the Phases step
    And I have completed the Secondary subjects step
    And I have completed the College subjects step
    And I have completed the Specialisms step

  Scenario: Completing the step with error
    Given I am on the 'Candidate experience details' page
    And I check 'Business dress'
    And I check 'Other'
    And I choose 'No' from the 'Do you provide parking for candidates?' radio buttons
    And I enter 'Carpark next door' into the 'Provide details of where candidates can park near your school.' text area
    And I choose 'No' from the 'Do you provide facilities or support for candidates with disabilities or access needs?' radio buttons
    And I enter '8:15 am' into the 'Start time' text area
    And I enter '4:30 pm' into the 'Finish time' text area
    And I choose 'Yes' from the 'Are your start and finish times flexible?' radio buttons
    When I submit the form
    Then I should see a validation error message

  Scenario: Completing the step
    Given I am on the 'Candidate experience details' page
    And I check 'Business dress'
    And I check 'Other'
    And I enter 'Must have nice hat' into the 'For example no denim, jeans, shorts, short skirts, trainers' text area
    And I choose 'No' from the 'Do you provide parking for candidates?' radio buttons
    And I enter 'Carpark next door' into the 'Provide details of where candidates can park near your school.' text area
    And I choose 'No' from the 'Do you provide facilities or support for candidates with disabilities or access needs?' radio buttons
    And I enter '8:15 am' into the 'Start time' text area
    And I enter '4:30 pm' into the 'Finish time' text area
    And I choose 'Yes' from the 'Are your start and finish times flexible?' radio buttons
    When I submit the form
    Then I should be on the 'Availability' page
