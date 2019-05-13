Feature: Administration Fee
  So candidates know where their money is going
  As a school administrator
  I want to provide details of the adminstration fees we charge

  Background: I have completed the previous steps
    Given I am logged in as a DfE user
    And the secondary school phase is availble
    And the college phase is availble
    And I have completed the following steps:
        | Step name              | Extra                              |
        | Candidate Requirements |                                    |
        | Fees                   | choosing only Administration costs |

  Scenario: Breadcrumbs
    Given I am already on the 'administration costs' page
    Then I should see the following breadcrumbs:
        | Text                 | Link     |
        | Some school          | /schools |
        | Administration costs | None     |

  Scenario: Completing the Administration costs step with error
    Given I have entered the following details into the form:
      | Explain what the fee covers. | Nondescript administration |
      | Explain how the fee is paid. | Travelers cheques          |
    And I choose 'Daily' from the 'Is this a daily or one-off fee?' radio buttons
    When I submit the form
    Then I should see a validation error message

  Scenario: Completing the Administration costs step with error
    Given I have entered the following details into the form:
      | Enter the number of pounds.  | 100                        |
      | Explain what the fee covers. | Nondescript administration |
      | Explain how the fee is paid. | Travelers cheques          |
    And I choose 'Daily' from the 'Is this a daily or one-off fee?' radio buttons
    When I submit the form
    Then I should be on the 'Phases' page
