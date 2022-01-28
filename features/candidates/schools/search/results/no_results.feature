Feature: Schools search page contents
    To keep me informed when my search yields no results
    As a potential candidate
    I want to see a clear and concise error message

    Scenario: No results in expanded area
        Given there are no schools in or around my search location
        When I search for schools within 5 miles
        Then the results page should include a warning that no results were found
        And there should be a link to Get into teaching

    Scenario: No results in expanded area and search outside England
        Given there are no schools in or around my search location
        And my search is outside of England
        When I search for schools within 5 miles
        Then there should be a message and link to get more information about teacher training