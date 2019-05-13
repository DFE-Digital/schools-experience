Feature: Phases
  So canidates know what education phases are available
  As a school administrator
  I want to specify what phases we offer school experience for

  Background: I have completed the wizard thus far
    Given I am logged in as a DfE user
    And the secondary school phase is availble
    And the college phase is availble
    And I have completed the following steps:
        | Step name                    | Extra                     |
        | Candidate Requirements       |                           |
        | Fees                         | choosing only Other costs |
        | Other costs                  |                           |

  Scenario: Breadcrumbs
    Given I am on the 'phases' page
    Then I should see the following breadcrumbs:
        | Text                            | Link     |
        | Some school                     | /schools |
        | Select school experience phases | None     |

  Scenario: Completing step choosing Primary phase only
    Given I am already on the 'phases' page
    And I check 'Primary'
    When I submit the form
    Then I should be on the 'Primary subjects list' page

  Scenario: Completing step choosing Secondary phase only
    Given I am on the 'phases' page
    And I check 'Secondary'
    When I submit the form
    Then I should be on the 'Subjects' page

  Scenario: Completing step chooisng Secondary and College phase
    Given I am on the 'phases' page
    And I check 'Secondary with 16 to 18 years'
    When I submit the form
    Then I should be on the 'Subjects' page

  Scenario: Completing step choosing multiple phases
    Given I am on the 'phases' page
    And I check 'Secondary'
    And I check '16 to 18 years'
    And I check 'Secondary with 16 to 18 years'
    When I submit the form
    Then I should be on the 'Subjects' page
