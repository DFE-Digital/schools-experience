Feature: Starting a request for experience at schools with different date options
    So I can apply for school experience in the most logical manner
    As a potential candidate
    I want to follow the most convenient path in the wizard

    Scenario: When the school has flexible dates
        Given my school of choice has 'flexible' dates
        When I am on the profile page for the chosen school
        Then the start button should link to the 'enter your personal details' page

    Scenario: When the school has fixed dates
        Given my school of choice has 'fixed' dates
        And my school of choice has entered some placement dates
        When I am on the profile page for the chosen school
        Then the start button should link to the 'enter your personal details' page
