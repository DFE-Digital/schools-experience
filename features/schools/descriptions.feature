Feature: Description
  So candidates know what makes our school unique
  As a school administrator
  I want to be able to highlight my schools specialisms

  Background: I have completed the wizard thus far
    Given I am logged in as a DfE user
    Given The secondary school phase is availble
    Given The college phase is availble
    And There are some subjects available
    And I have completed the Candidate Requirements step
    And I have completed the Fees step, choosing only Other costs
    And I have completed the Other costs step
    And I have completed the Phases step
    And I have completed the Subjects step

  Scenario: Completing the step with description
    Given I am on the 'Description' page
    And I enter 'We have a race track' into the 'Tell us about your school. Provide a summary to help candidates choose your school.' text area
    When I submit the form
    Then I should be on the 'Candidate experience details' page
