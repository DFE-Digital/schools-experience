Feature: Phases
  So canidates know what education phases are available
  As a school administrator
  I want to specify what phases we offer school experience for

  Background: I have completed the wizard thus far
    Given The secondary school phase is availble
    Given The college phase is availble
    Given I have completed the Candidate Requirements step
    And I have completes the Fees step, choosing only Other costs
    And I have completed the Other costs step

  Scenario: Completing step choosing Primary phase only
    Given I am on the 'phases' page
    And I check 'Primary'
    When I submit the form
    Then I should be on the 'Primary subjects list' page

  Scenario: Completing step choosing Secondary phase only
    Given I am on the 'phases' page
    And I check 'Secondary'
    When I submit the form
    Then I should be on the 'Secondary subjects' page

  Scenario: Completing step choosing College phase only
    Given I am on the 'phases' page
    And I check '16 to 18 years'
    When I submit the form
    Then I should be on the 'College subjects' page

  Scenario: Completing step choosing multiple phases
    Given I am on the 'phases' page
    And I check 'Secondary'
    And I check '16 to 18 years'
    When I submit the form
    Then I should be on the 'Secondary subjects' page
