Feature: Availability description
  So candidates know when we offer school experience
  As a school administrator
  I want to specify our availability

  Background: I have completed the wizard thus far
    Given I am logged in as a DfE user
    And the secondary school phase is availble
    And the college phase is availble
    And there are some subjects available
    And I have completed the following steps:
        | Step name                    | Extra                     |
        | Candidate Requirements       |                           |
        | Fees                         | choosing only Other costs |
        | Other costs                  |                           |
        | Phases                       |                           |
        | Subjects                     |                           |
        | Description                  |                           |
        | Candidate experience details |                           |
        | Availability preference      |                           |

  Scenario: Page title
    Given I am already on the 'availability description' page
    Then the page title should be 'Describe your school experience availability'

  Scenario: Breadcrumbs
    Given I am already on the 'availability description' page
    Then I should see the following breadcrumbs:
        | Text                                         | Link     |
        | Some school                                  | /schools |
        | Describe your school experience availability | None     |

  Scenario: Completing the step with error
    Given I am on the 'Availability description' page
    When I submit the form
    Then I should see a validation error message

  Scenario: Completing the step
    Given I am on the 'Availability description' page
    And I enter 'Whenever really' into the 'Outline when you offer school experience at your school.' text area
    When I submit the form
    Then I should be on the 'Experience Outline' page
