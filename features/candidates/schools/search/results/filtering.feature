Feature: Filtering school search results
    To help me hone a search
    As a potential candidate
    I want to be able to narrow down search results

    Background:
        Given the phases 'Primary' and 'Secondary' exist

    Scenario: Filtering by Education Phase
        Given I have searched for 'Manchester' and am on the results page
        Then I should see a 'Education phases' filter on the left
        And it should have the hint text 'Select all that apply'
        And it should have checkboxes for the following items:
            | Primary   |
            | Secondary |

    Scenario: Filtering by Subject
        Given there are some subjects
        When I have searched for 'Manchester' and am on the results page
        Then I should see a 'Subjects' filter on the left
        And it should have the hint text 'Select all that apply'
        And it should have checkboxes for all subjects

    Scenario: Filtering while searching by current location (JS disabled)
        Given there are schools with the following attributes:
            | Name              | Phase     | Location   |
            | Manchester School | Secondary | Manchester |
            | Rochdale School   | Secondary | Rochdale   |
            | Burnley School    | Primary   | Burnley    |
        And I have provided a point in 'Bury' as my location
        And there are both 'Primary' and 'Secondary' schools in the results
        And I check the 'Secondary' filter box
        When I click the 'Update schools list' button
        Then only 'Secondary' schools should remain in the results

    # Disabled Javascript scenario which requires Selenium+javascript to run (incompatible with Alpine 3.21)
    @wip
    Scenario: Filtering while searching by current location (JS enabled)
        Given there are schools with the following attributes:
            | Name              | Phase     | Location   |
            | Manchester School | Secondary | Manchester |
            | Rochdale School   | Secondary | Rochdale   |
            | Burnley School    | Primary   | Burnley    |
        And I have provided a point in 'Bury' as my location
        And there are both 'Primary' and 'Secondary' schools in the results
        And I check the 'Secondary' filter box
        When the results have finished loading
        Then only 'Secondary' schools should remain in the results
        When I click the 'Secondary' tag
        And the results have finished loading
        Then there are both 'Primary' and 'Secondary' schools in the results
