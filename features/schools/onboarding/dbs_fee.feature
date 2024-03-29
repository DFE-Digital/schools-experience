Feature: DBS Fee
  So candidates know where their money is going
  As a school administrator
  I want to provide details of the DBS fees we charge

  Background: I have completed the previous steps
    Given I am logged in as a DfE user
    And the secondary school phase is availble
    And the college phase is availble
    And I have completed the following steps:
        | Step name                        | Extra                   |
        | DBS Requirements                 |                         |
        | Candidate Requirements selection |                         |
        | Fees                             | choosing only DBS costs |

  Scenario: Page title
    Given I am on the 'dbs check costs' page
    Then the page title should be 'DBS check costs'

  Scenario: Completing the DBS costs step with error
    Given I have entered the following details into the form:
      | Add extra details           | Background checks |
      | Explain how the fee is paid | Ethereum          |
    When I submit the form
    Then I should see a validation error message

  Scenario: Completing the DBS costs step without error
    Given I have entered the following details into the form:
      | Enter the number of pounds  | 200               |
      | Add extra details           | Background checks |
      | Explain how the fee is paid | Ethereum          |
    When I submit the form
    Then I should be on the 'Phases' page
