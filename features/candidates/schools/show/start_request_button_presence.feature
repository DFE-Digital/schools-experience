Feature: School has no availability
    To prevent me from applying to a school that can't accomodate me
    As a potential candidate
    I want the 'Start request' button to be hidden if there is no availability

    Scenario: When the school has flexible dates
        Given my school of choice has 'flexible' dates
        When I am on the profile page for the chosen school
        Then there should be a button called 'Start request' that begins the wizard

    Scenario: When the school has fixed dates but none are available
        Given my school of choice has 'fixed' dates
        When I am on the profile page for the chosen school
        Then there should not be a button called 'Start request' that begins the wizard

    Scenario: When the school has fixed dates and some are available
        Given my school of choice has 'fixed' dates
        And there are some available dates in the future
        When I am on the profile page for the chosen school
        Then there should be a button called 'Start request' that begins the wizard
