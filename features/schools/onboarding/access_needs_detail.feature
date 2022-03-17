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
        | Candidate Requirements selection |                           |
        | Fees                             | choosing only Other costs |
        | Other costs                      |                           |
        | Phases                           |                           |
        | Subjects                         |                           |
        | Description                      |                           |
        | Candidate dress code             |                           |
        | Candidate parking information    |                           |
        | Candidate experience schedule    |                           |
        | Access needs support             |                           |

  Scenario: Page title
    Given I am on the 'Access needs detail' page
    Then the page title should be 'Access needs details'

  Scenario: Submitting the form with error
    Given I am on the 'Access needs detail' page
    And I enter '' into the 'schools-on-boarding-access-needs-detail-description-field' text area
    When I submit the form
    Then the page title should be 'Access needs details'
    And I should see a validation error message

  Scenario: Submitting the form successfully
    Given I am on the 'Access needs detail' page
    And I enter 'Some text' into the 'schools-on-boarding-access-needs-detail-description-field' text area
    When I submit the form
    Then I should be on the 'Disability confident' page
