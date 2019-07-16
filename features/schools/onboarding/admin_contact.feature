Feature: Admin contact
  So candidates know who to contact
  As a school administrator
  I want to be able to specify the school experience admin contact's details

  Background: I have completed the wizard thus far
    Given I am logged in as a DfE user
    And A school is returned from DFE sign in
    And the secondary school phase is availble
    And the college phase is availble
    And there are some subjects available
    And I have completed the following steps:
        | Step name                    | Extra                     |
        | Candidate Requirements       |                           |
        | Fees                         | choosing only Other costs |
        | Other costs                  |                           |
        | Phases                       |                           |
        | Subjects                     |                           |
        | Description                  |                           |
        | Candidate experience details |                           |
        | Experience Outline           |                           |

  Scenario: Page title
    Given I am on the 'Admin contact' page
    Then the page title should be 'Enter school experience admin contact details'

  Scenario: Completing the step with error
    Given I am on the 'Admin contact' page
    And I enter '01234567890' into the 'UK telephone number' text area
    When I submit the form
    Then I should see a validation error message

  Scenario: Completing the step without error
    Given I am on the 'Admin contact' page
    And I enter '01234567890' into the 'UK telephone number' text area
    And I enter 'g.chalmers@springfield.edu' into the 'Email address' text area
    And I enter 's.skinner@springfield.edu' into the 'Email address 2' text area
    When I submit the form
    Then I should be on the 'Profile' page
