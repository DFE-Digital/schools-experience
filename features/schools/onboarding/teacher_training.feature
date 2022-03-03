Feature: Teacher training
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
        | Candidate dress code             |                           |
        | Candidate experience details     |                           |
        | Experience Outline               |                           |

  Scenario: Page title
    Given I am on the 'Teacher training' page
    Then the page title should be 'Teacher training details'

  Scenario: Completing the step with error
    Given I am on the 'Teacher training' page
    And I choose 'Yes' from the 'Do you run your own teacher training or have any links to teacher training organisations and providers?' radio buttons
    When I submit the form
    Then I should see a validation error message

  Scenario: Completing the step
    Given I am on the 'Teacher training' page
    And I choose 'Yes' from the 'Do you run your own teacher training or have any links to teacher training organisations and providers?' radio buttons
    And I enter 'We run our own training' into the 'Provide details.' text area
    And I enter 'http://example.com' into the 'Enter a web address.' text area
    When I submit the form
    Then I should be on the 'Admin contact' page
