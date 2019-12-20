Feature: Accepting a request
    So I can allow candidates to visit my school
    As a school administrator
    I want to be able to accept their placement requests

    Background:
        Given I am logged in as a DfE user
        And the school has subjects

    Scenario: Accepting a fixed booking for a future date
        Given my school has fixed dates
        And there is a new placement request with a future date
        When I am on the 'placement request' screen for that placement request
        Then the 'Accept request' link should take me to the 'confirm booking' page

    Scenario: Accepting a fixed booking for a past date
        Given my school has fixed dates
        And there is a new placement request with a past date
        When I am on the 'placement request' screen for that placement request
        Then the 'Accept request' link should take me to the 'make changes' page

    Scenario: Accepting a flexible booking
        Given my school has flexible dates
        And there is a new placement request
        When I am on the 'placement request' screen for that placement request
        Then the 'Accept request' link should take me to the 'make changes' page
