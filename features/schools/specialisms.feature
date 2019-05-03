Feature: Specialisms
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

  Scenario: Completing the step without choosing an option
    Given I am on the 'Specialisms' page
    When I submit the form
    Then I should see a validation error message

  Scenario: Completing the step with specialisms
    Given I am on the 'Specialisms' page
    And I choose 'No' from the 'Tell us about what might make your school interesting to candidates.' radio buttons
    When I submit the form
    Then I should be on the 'Candidate experience details' page

  Scenario: Completing the step without specialisms
    Given I am on the 'Specialisms' page
    And I choose 'Yes' from the 'Tell us about what might make your school interesting to candidates.' radio buttons
    And I enter 'Race track' into the 'Provide details' text area
    When I submit the form
    Then I should be on the 'Candidate experience details' page
