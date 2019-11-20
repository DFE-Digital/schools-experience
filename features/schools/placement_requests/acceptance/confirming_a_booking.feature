Feature: Confirming a booking
    So I can quickly accept a placement request
    As a school administrator
    I want to be able check and accept a booking in one step

    Background:
        Given I am logged in as a DfE user
        And the school has subjects
        And the school has fixed dates
        And there is a new placement request with a future date

    Scenario: Page content: when the school has no prior bookings
        Given I am on the 'confirm booking' page for the placement request
        When the school has no prior accepted placement requests
        Then there should be a list with the following subheadings:
            | School            |
            | Date requested    |
            | Subject requested |
            | Admin details     |
        And there should be a 'Continue' link to the 'make changes' page

    Scenario: Page content: when the school has prior bookings
        Given the school has a prior booking
        And I am on the 'confirm booking' page for the placement request
        When the school has no prior accepted placement requests
        Then there should be a list with the following subheadings:
            | School            |
            | Date requested    |
            | Subject requested |
            | Contact details   |
            | Admin details     |
        And there should be an 'Accept request' button and a 'Make changes' link

    Scenario: Confirming a booking
        Given the school has a prior booking
        And I am on the 'confirm booking' page for the placement request
        When I click the 'Accept request' button
        Then I should be on the 'preview confirmation email' page for the placement request
