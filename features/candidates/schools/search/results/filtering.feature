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
        Then I should see a 'Placement subjects' filter on the left
        And it should have the hint text 'Select all that apply'
        And it should have checkboxes for all subjects
