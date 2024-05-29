Feature: Schools search page sorting
    To help me find the ideal school
    As a potential candidate
    I want to see the results sorted by distance

    @javascript
    Scenario: Sorting by distance when searching by a specified location
        Given there are schools with the following attributes:
            | Name              | Location   |
            | Manchester School | Manchester |
            | Rochdale School   | Rochdale   |
            | Burnley School    | Burnley    |
        And I have provided 'Bury' as my location
        Then the results should be sorted by distance, nearest to furthest
