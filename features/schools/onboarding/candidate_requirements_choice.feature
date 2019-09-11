Feature: Candidates requirements choice
  Background:
    Given the primary phase is available
    And the secondary school phase is availble
    And the college phase is availble
    And I am logged in as a DfE user
    And the school has subjects
    And I have completed the following steps:
        | Step name                    | Extra |
        | DBS Requirements             |       |

  Scenario: Page title
    Then the page title should be 'Do you have any candidate requirements?'

  Scenario: Completing the step choosing yes
    Given I choose 'Yes' from the 'Do you have any candidate requirements?' radio buttons
    When I submit the form
    Then I should be on the 'candidate requirements selection' page

  Scenario: Completing the step choosing yes
    Given I choose 'No' from the 'Do you have any candidate requirements?' radio buttons
    When I submit the form
    Then I should be on the 'fees charged' page

  Scenario: Editing choice from no to yes
    Given I have completed the following steps:
        | Step name                        | Extra                     |
        | DBS Requirements                 |                           |
        | Candidate Requirements choice    | choosing No               |
        | Fees                             | choosing only Other costs |
        | Other costs                      |                           |
        | Phases                           |                           |
        | Subjects                         |                           |
        | Description                      |                           |
        | Candidate experience details     |                           |
        | Access needs support             |                           |
        | Experience Outline               |                           |
        | Admin contact                    |                           |
    And I am on the 'edit Candidate requirements choice' page
    And I choose 'Yes' from the 'Do you have any candidate requirements?' radio buttons
    When I submit the form
    Then I should be on the 'candidate requirements selection' page

  Scenario: Editing choice from yes to no
    Given I have completed the following steps:
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
        | Experience Outline               |                           |
        | Admin contact                    |                           |
    And I am on the 'edit Candidate requirements choice' page
    And I choose 'No' from the 'Do you have any candidate requirements?' radio buttons
    When I submit the form
    Then I should be on the 'profile' page

  Scenario: Editing choice from keeping yes selected
    Given I have completed the following steps:
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
        | Experience Outline               |                           |
        | Admin contact                    |                           |
    And I am on the 'edit Candidate requirements choice' page
    And I choose 'Yes' from the 'Do you have any candidate requirements?' radio buttons
    When I submit the form
    Then I should be on the 'candidate requirements selection' page
