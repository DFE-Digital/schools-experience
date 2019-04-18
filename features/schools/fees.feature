Feature: Fees
  So I can ensure we don't surprise candidates
  As a school administrator
  I want to specify the fees we charge candidates for their placement

  Background: I have completed the candidate requirement step
    Given I am logged in as a DfE user
    Given The secondary school phase is availble
    Given The college phase is availble
    And I have completed the Candidate Requirements step

  Scenario: Completing step choosing Adminsitration costs only
    Given I am on the 'fees charged' page
    And I check 'Administration costs'
    When I submit the form
    Then I should be on the 'Administration costs' page

  Scenario: Completing step choosing DBS costs only
    Given I am on the 'fees charged' page
    And I check 'DBS check costs'
    When I submit the form
    Then I should be on the 'DBS check costs' page

  Scenario: Completing step choosing Other costs only
    Given I am on the 'fees charged' page
    And I check 'Other costs'
    When I submit the form
    Then I should be on the 'Other costs' page

  Scenario: Completing step choosing all costs
    Given I am on the 'fees charged' page
    And I check 'Administration costs'
    And I check 'DBS check costs'
    And I check 'Other costs'
    When I submit the form
    Then I should be on the 'Administration costs' page

  Scenario: Completing step choosing no costs
    Given I am on the 'fees charged' page
    When I submit the form
    Then I should be on the 'Phases' page
