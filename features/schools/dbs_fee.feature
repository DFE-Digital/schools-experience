Feature: DBS Fee
  So candidates know where their money is going
  As a school administrator
  I want to provide details of the DBS fees we charge

  Background: I have completed the previous steps
    Given I am logged in as a DfE user
    Given The secondary school phase is availble
    Given The college phase is availble
    Given I have completed the Candidate Requirements step
    And I have completed the Fees step, choosing only DBS costs

  Scenario: Completing the DBS costs step with error
    Given I have entered the following details into the form:
      | Explain what the fee covers. | Background checks |
      | Explain how the fee is paid. | Ethereum          |
    And I choose 'Daily' from the 'Is this a daily or one-off fee?' radio buttons
    When I submit the form
    Then I should see a validation error message

  Scenario: Completing the DBS costs step with error
    Given I have entered the following details into the form:
      | Enter the number of pounds.  | 200               |
      | Explain what the fee covers. | Background checks |
      | Explain how the fee is paid. | Ethereum          |
    And I choose 'Daily' from the 'Is this a daily or one-off fee?' radio buttons
    When I submit the form
    Then I should be on the 'Phases' page
