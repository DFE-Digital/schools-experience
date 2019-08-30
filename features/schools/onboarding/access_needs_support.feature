Feature: Access needs support

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

  Scenario: Page title
    Given I am on the 'Access needs support' page
    Then the page title should be 'Access needs support'

  Scenario: Submitting the form with error
    Given I am on the 'Access needs support' page
    When I submit the form
    Then the page title should be 'Access needs support'

  Scenario: Submitting the form successfully
    Given I am on the 'Access needs support' page
    And I choose 'Yes' from the 'Do you want to add details about how you can support candidates with disabilites and access needs?' radio buttons
    When I submit the form
    Then I should be on the 'Experience Outline' page
