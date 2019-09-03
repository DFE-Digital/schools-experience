Feature: Candidates requirements choice
  Background:
    Given I am logged in as a DfE user
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
