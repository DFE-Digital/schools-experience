Feature: Candidate dress code
  So candidates know what to wear
  As a school administrator
  I want to specify our dress code

  Background: I have completed the wizard thus far
    Given I am logged in as a DfE user
    And the secondary school phase is availble
    And the college phase is availble
    And there are some subjects available
    And I have completed the following steps:
      | Step name                        | Extra                     |
      | DBS Requirements                 |                           |
      | Candidate Requirements selection |                           |
      | Fees                             | choosing only Other costs |
      | Other costs                      |                           |
      | Phases                           |                           |
      | Subjects                         |                           |
      | Description                      |                           |

  Scenario: Page title
    Given I am already on the 'candidate dress code' page
    Then the page title should be 'Enter dress code details for candidates'

  Scenario: Completing the step with error
    Given I am on the 'Candidate dress code' page
    And I complete the candidate dress code form with invalid data
    When I submit the form
    Then I should see a validation error message

  Scenario: Completing the step without error
    Given I am on the 'Candidate dress code' page
    And I complete the candidate dress code form with valid data
    When I submit the form
    Then I should be on the 'Candidate parking information' page
