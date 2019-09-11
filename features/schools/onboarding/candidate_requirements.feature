Feature: Candidate requirements
  So I can ensure we accept suitable candidates
  As a school administrator
  I want to specify candidate requirements

  Background:
    Given I am logged in as a DfE user
    Given I see the candidate requirements screen
    And I have completed the following steps:
        | Step name                    | Extra |
        | DBS Requirements             |       |
    And I am on the 'candidate requirements' page

  Scenario: Page title
    Then the page title should be 'Enter your school experience details'

  Scenario: Breadcrumbs
    Then I should see the following breadcrumbs:
        | Text                                 | Link               |
        | Some school                          | /schools/dashboard |
        | Enter your school experience details | None               |

  Scenario: Completing step
    Given I choose 'Yes' from the 'Do you have any requirements for school experience candidates?' radio buttons
    And I provide details
    When I submit the form
    Then I should be on the 'fees charged' page
