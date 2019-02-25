Feature: Schools search page contents
    To help me find the ideal school
    As a potential candidate
    I want to be able to see and understand search results

    Background:
        Given the phases 'Primary' and 'Secondary' exist
        Given there are some schools with a range of fees containing the word 'Manchester'

    Scenario: Search result contents
        Given I have searched for 'Manchester' and am on the results page
        And there are 3 results
        Then each result should have the following information
            | Address     |
            | Education   |
            | Fees        |
            | School type |
            | Subjects    |
