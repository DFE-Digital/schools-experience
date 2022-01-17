Feature: Experience Outline
  So candidates know what to expect
  As a school administrator
  I want to be able to outline what to expect from the experience

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
        | Access needs support             |                           |
        | Access needs detail              |                           |
        | Disability confident             |                           |
        | Access needs policy              |                           |
        | Candidate experience details     |                           |

  Scenario: Page title
    Given I am on the 'Experience Outline' page
    Then the page title should be 'School experience details'

  Scenario: Completing the step
    Given I am on the 'Experience Outline' page
    And I enter 'A really good one' into the 'What kind of school experience do you offer?' text area
    When I submit the form
    Then I should be on the 'Teacher training' page
