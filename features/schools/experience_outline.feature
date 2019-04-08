Feature: Experience Outline
  So candidates know what to expect
  As a school administrator
  I want to be able to outline what to expect from the experience

  Background: I have completed the wizard thus far
    Given The secondary school phase is availble
    Given The college phase is availble
    And There are some subjects available
    And I have completed the Candidate Requirements step
    And I have completes the Fees step, choosing only Other costs
    And I have completed the Other costs step
    And I have completed the Phases step
    And I have completed the Secondary subjects step
    And I have completed the College subjects step
    And I have completed the Specialisms step
    And I have completed the Candidate experience details step

  Scenario: Completing the step with error
    Given I am on the 'Experience Outline' page
    And I enter 'A really good one' into the 'What kind of school experience do you offer candidates?' text area
    And I choose 'Yes' from the 'Do you run your own teacher training or have any links to teacher training organisations and providers?' radio buttons
    When I submit the form
    Then I should see a validation error message

  Scenario: Completing the step
    Given I am on the 'Experience Outline' page
    And I enter 'A really good one' into the 'What kind of school experience do you offer candidates?' text area
    And I choose 'Yes' from the 'Do you run your own teacher training or have any links to teacher training organisations and providers?' radio buttons
    And I enter 'We run our own training' into the 'Provide details.' text area
    And I enter 'http://example.com' into the 'Enter a web address.' text area
    When I submit the form
    Then I should be on the 'Admin contact information' page
