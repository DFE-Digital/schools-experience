Feature: Candidate experience details
  So canidates know our requirements
  As a school administrator
  I want to specify our requirements for candidates

  Background: I have completed the wizard thus far
    Given I am logged in as a DfE user
    And the secondary school phase is availble
    And the college phase is availble
    And there are some subjects available
    And I have completed the following steps:
        | Step name                        | Extra                     |
        | DBS Requirements                 |                           |
        | Candidate Requirements choice    |                           |
        | Candidate Requirements selection |                           |
        | Fees                             | choosing only Other costs |
        | Other costs                      |                           |
        | Phases                           |                           |
        | Subjects                         |                           |
        | Description                      |                           |

  Scenario: Page title
    Given I am already on the 'candidate experience details' page
    Then the page title should be 'Enter school experience details for candidates'

  Scenario: Completing the step with error
    Given I am on the 'Candidate experience details' page
    And I complete the candidate experience form with invalid data
    When I submit the form
    Then I should see a validation error message

  Scenario: Completing the step without error
    Given I am on the 'Candidate experience details' page
    And I complete the candidate experience form with valid data
    When I submit the form
    Then I should be on the 'access needs support' page
