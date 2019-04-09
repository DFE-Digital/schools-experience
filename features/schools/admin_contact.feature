Feature: Admin contact
  So candidates know who to contact
  As a school administrator
  I want to be able to specify the school experience admin contact's details

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
    And I have completed the Experience Outline step

  Scenario: Completing the step with error
    Given I am on the 'Admin contact' page
    And I enter 'Gary Chalmers' into the 'Full name' text area
    And I enter '01234567890' into the 'UK telephone number' text area
    When I submit the form
    Then I should see a validation error message

  Scenario: Completing the step with error
    Given I am on the 'Admin contact' page
    And I enter 'Gary Chalmers' into the 'Full name' text area
    And I enter '01234567890' into the 'UK telephone number' text area
    And I enter 'g.chalmers@springfield.edu' into the 'Email address' text area
    When I submit the form
    Then I should be on the 'Profile' page
