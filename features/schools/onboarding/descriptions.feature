Feature: Description
  So candidates know what makes our school unique
  As a school administrator
  I want to be able to highlight my schools specialisms

  Background: I have completed the wizard thus far
    Given I am logged in as a DfE user
    Given the secondary school phase is availble
    Given the college phase is availble
    And there are some subjects available
    And I have completed the following steps:
        | Step name                    | Extra                     |
        | Candidate Requirements       |                           |
        | Fees                         | choosing only Other costs |
        | Other costs                  |                           |
        | Phases                       |                           |
        | Subjects                     |                           |

  Scenario: Page title
    Given I am on the 'description' page
    Then the page title should be 'Enter a short description of your school'

  Scenario: Breadcrumbs
    Given I am already on the 'description' page
    Then I should see the following breadcrumbs:
        | Text                                     | Link     |
        | Some school                              | /schools |
        | Enter a short description of your school | None     |

  Scenario: Completing the step with description
    Given I am on the 'Description' page
    And I enter 'We have a race track' into the 'Tell us about your school. Provide a summary to help candidates choose your school.' text area
    When I submit the form
    Then I should be on the 'Candidate experience details' page
