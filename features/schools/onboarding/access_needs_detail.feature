Feature: Access needs detail
  Background: I have completed the wizard thus far
    Given I am logged in as a DfE user
    And A school is returned from DFE sign in
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
        | Candidate experience details     |                           |
        | Access needs support             |                           |

  Scenario: Page title
    Given I am on the 'Access needs detail' page
    Then the page title should be 'Access needs details'

  Scenario: Submitting the form successfully
    Given I am on the 'Access needs detail' page
    When I submit the form
    Then I should be on the 'Experience outline' page
