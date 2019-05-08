Feature: Availability description
  So candidates know when we offer school experience
  As a school administrator
  I want to specify our availability

  Background: I have completed the wizard thus far
    Given I am logged in as a DfE user
    Given The secondary school phase is availble
    Given The college phase is availble
    And There are some subjects available
    And I have completed the Candidate Requirements step
    And I have completed the Fees step, choosing only Other costs
    And I have completed the Other costs step
    And I have completed the Phases step
    And I have completed the Subjects step
    And I have completed the Description step
    And I have completed the Candidate experience details step
    And I have completed the Availability preference step

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
