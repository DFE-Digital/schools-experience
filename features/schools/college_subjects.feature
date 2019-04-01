Feature: College Subjects
  So candidates know what college subjects we offer for school experience
  As a school administrator
  I want to specify what college we offer for school experience

  Background: I have completed the wizard thus far
    Given The secondary school phase is availble
    Given The college phase is availble
    And There are some subjects available
    And I have completed the Candidate Requirements step
    And I have completes the Fees step, choosing only Other costs
    And I have completed the Other costs step
    And I have complete the Phases step
    And I have complete the Secondary subjects step

  Scenario: Completing the step choosing no subjects
    Given I am on the 'College subjects' page
    When I submit the form
    Then I should see a validation error message

  Scenario: Completing the step choosing some subjects
    Given I am on the 'College subjects' page
    And I check 'Maths'
    When I submit the form
    Then I should be on the 'Specialisms' page
