Feature: Schools search page
    To help me narrow down results
    As a potential candidate
    I want to be able to narrow down search results

    Background:
        Given the phases 'Primary' and 'Secondary' exist
        Given there are some schools with a range of fees containing the word 'Manchester'
    
    @onlylocalapp
    Scenario: Search result contents
        Given I have searched for 'Manchester' and am on the results page
        And there are 3 results
        Then each result should have the following information
            | Address     |
            | Education   |
            | Fees        |
            | School type |
            | Subjects    |
    
    @onlylocalapp
    Scenario: Filtering by Education Phase
        Given I have searched for 'Manchester' and am on the results page
        Then I should see a 'Phases' filter on the left
        And it should have the hint text 'Select all that apply'
        And it should have checkboxes for the following items:
            | Primary   |
            | Secondary |

    @onlylocalapp
    Scenario: Filtering by Fees
        Given there are some subjects
        When I have searched for 'Manchester' and am on the results page
        Then I should see a 'Max fee' filter on the left
        And it should have the hint text 'Schools may charge'
        And it should have radio buttons for the following items:
            | None      |
            | up to £30 |
            | up to £60 |
            | up to £90 |

    Scenario: Filtering by Subject
        Given there are some subjects
        When I have searched for 'Manchester' and am on the results page
        Then I should see a 'Subject' filter on the left
        And it should have the hint text 'Select all that apply'
        And it should have checkboxes for all subjects

    Scenario: Sorting by distance
        Given I have searched for 'Manchester' and provided my location
        When I select 'Distance' in the 'Sorted by' select box
        Then the results should be sorted by distance, nearest to furthest

    Scenario: Sorting by fee
        Given I have searched for 'Manchester' and am on the results page
        When I select 'Fee' in the 'Sorted by' select box
        Then the results should be sorted by fee, lowest to highest
