Feature: Candidate requirements
  So I can ensure we accept suitable candidates
  As a school administrator
  I want to specify candidate requirements

  Background:
    Given I am logged in as a DfE user

  Scenario: Breadcrumbs
    Given I am on the 'candidate requirements' page
    Then I should see the following breadcrumbs:
        | Text                                 | Link     |
        | Some school                          | /schools |
        | Enter your school experience details | None     |

  @javascript
  Scenario: Completing step
    Given I am on the 'candidate requirements' page
    And I choose 'Yes - Sometimes' from the 'Do you require candidates to be DBS-checked?' radio buttons
    And I outline our dbs policy
    And I choose 'Yes' from the 'Do you have any requirements for school experience candidates?' radio buttons
    And I provide details
    When I submit the form
    Then I should be on the 'fees charged' page
