Feature: Schools search page sorting
    To help me find the ideal school
    As a potential candidate
    I want to be able to sort results by various criteria

    @javascript
    Scenario: Sorting by distance when searching by a specified location
        Given there there are schools with the following attributes:
            | Name              | Location   |
            | Manchester School | Manchester |
            | Rochdale School   | Rochdale   |
            | Burnley School    | Burnley    |
        And I have provided 'Bury' as my location
        And I have changed the sort order to 'Name'
        When I select 'Distance' from the 'Sorted by' radio buttons
        Then the results should be sorted by distance, nearest to furthest

    @javascript
    Scenario: Sorting by distance when searching by current location
        Given there there are schools with the following attributes:
            | Name              | Location   |
            | Manchester School | Manchester |
            | Rochdale School   | Rochdale   |
            | Burnley School    | Burnley    |
        And I have provided a point in 'Bury' as my location
        And I have changed the sort order to 'Name'
        When I select 'Distance' from the 'Sorted by' radio buttons
        Then the results should be sorted by distance, nearest to furthest

    @javascript
    Scenario: When sorted by distance the mileage should increase
        Given there there are schools with the following attributes:
            | Name              | Location   |
            | Manchester School | Manchester |
            | Rochdale School   | Rochdale   |
            | Burnley School    | Burnley    |
        And I have provided a point in 'Bury' as my location
        And I have changed the sort order to 'Name'
        When I select 'Distance' from the 'Sorted by' radio buttons
        Then the distance should be ordered from low to high

    @javascript
    Scenario: Sorting by name
        Given there there are schools with the following attributes:
            | Name                       | Location   |
            | Manton School              | Manchester |
            | Mansfield School           | Rochdale   |
            | Manningtree Primary School | Burnley    |
        And I have searched for 'Man' and am on the results page
        And the sort order has defaulted to 'Distance'
        When I select 'Name' from the 'Sorted by' radio buttons
        Then the results should be sorted by name, lowest to highest
