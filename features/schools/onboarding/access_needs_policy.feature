Feature: Access needs policy
  So candidates know what to expect
  As a school administrator
  I want to be able to link to our access needs policy

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
        | Candidate experience details     |                           |
        | Access needs support             |                           |
        | Access needs detail              |                           |
        | Disability confident             |                           |

  Scenario: Page title
    Given I am on the 'Access needs policy' page
    Then the page title should be 'Access needs policy'

  Scenario: Submitting the form with error
    Given I am on the 'Access needs policy' page
    When I submit the form
    Then the page title should be 'Access needs policy'

  Scenario: Submitting the form successfully choosing yes
    Given I am on the 'Access needs policy' page
    And I choose 'Yes' from the 'Do you have any online information which covers your disability and access needs policy?' radio buttons
    And I enter 'https://example.com' into the 'Enter web address.' text area
    When I submit the form
    Then I should be on the 'Experience outline' page

  Scenario: Submitting the form successfully choosing yes
    Given I am on the 'Access needs policy' page
    And I choose 'No' from the 'Do you have any online information which covers your disability and access needs policy?' radio buttons
    When I submit the form
    Then I should be on the 'Experience outline' page
