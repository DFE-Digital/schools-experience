Feature: Availability preference
  So I am presented with the correct screen to enter our availablity
  As a school administrator
  I want to specify what kind of dates we offer for school experience

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

  Scenario: Breadcrumbs
    Given I am already on the 'availability preference' page
    Then I should see the following breadcrumbs:
        | Text                                          | Link     |
        | Some school                                   | /schools |
        | School experience availability or fixed dates | None     |

  Scenario: Completing the step with error
    Given I am on the 'Availability preference' page
    When I submit the form
    Then I should see a validation error message

  Scenario: Completing the step with flexible dates
    Given I am on the 'Availability preference' page
    And I choose "If you're flexible on dates, describe your school experience availability." from the 'Enter school experience availability or fixed dates' radio buttons
    When I submit the form
    Then I should be on the 'Availability description' page

  Scenario: Completing the step with fixed dates
    Given I am on the 'Availability preference' page
    And I choose 'If you only offer fixed dates, state when you provide school experience.' from the 'Enter school experience availability or fixed dates' radio buttons
    When I submit the form
    Then I should be on the 'Experience Outline' page
