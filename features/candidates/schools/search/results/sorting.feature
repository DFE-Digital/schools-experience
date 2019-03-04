Feature: Schools search page sorting
    To help me find the ideal school
    As a potential candidate
    I want to be able to sort results by various criteria

    Background:
        Given there there are schools with the following attributes:
            | Name              | Fee | Location   |
            | Manchester School | 30  | Manchester |
            | Rochdale School   | 10  | Rochdale   |
            | Burnley School    | 20  | Burnley    |

    @javascript
    Scenario: Sorting by distance
        Given I have searched for 'School' and provided 'Bury' for my location
        When I select 'Distance' in the 'Sorted by' select box
        Then the results should be sorted by distance, nearest to furthest

    @javascript
    Scenario: Sorting by fee
        Given I have searched for 'School' and am on the results page
        When I select 'Fee' in the 'Sorted by' select box
        Then the results should be sorted by fee, lowest to highest
