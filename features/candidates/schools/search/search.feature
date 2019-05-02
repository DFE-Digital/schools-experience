Feature: Schools search page
    To help me find a suitable school
    As a potential candidate
    I want to be able to search for schools in my area

    Scenario: Page contents
        Given I am on the 'find a school' page
        Then the page should have a heading called 'Find school experience'

    Scenario: Search form
        Given I am on the 'find a school' page
        Then I should see the school search form
        And it should have a blank search field
        And there should be a 'Distance' select box with the following options:
            | 1  | 1 mile   |
            | 3  | 3 miles  |
            | 5  | 5 miles  |
            | 10 | 10 miles |
            | 15 | 15 miles |
            | 20 | 20 miles |
            | 25 | 25 miles |
        And the submit button should be labelled 'Find'

    Scenario: Search form client-side validation
        Given I am on the 'find a school' page
        Then the 'location' input should require at least '3' characters

    Scenario: Navigating back to the search form
        Given I search for schools near 'Rochdale'
        When I click back on the results screen
        Then the location input should be populated with 'Rochdale'

    Scenario: Entering an invalid search
        Given I search for schools near 'Ex'
        Then I should see an error message stating 'Must be at least 3 characters'
