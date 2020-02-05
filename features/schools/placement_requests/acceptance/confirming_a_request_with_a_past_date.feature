Feature: Confirming a request with a future date
    So I can quickly accept a placement request
    As a school administrator
    I want to be able check and accept a booking in one step

    Background:
        Given I am logged in as a DfE user
        And the school has subjects
        And the school has fixed dates
        And there is a new placement request with a past date

    Scenario: Page content: when the school has no prior bookings
        Given I am on the 'make changes' page for the placement request
        Then there should be a 'elapsed' warning
        And I should see a form with the following fields:
            | Label            | Type   | Options                 |
            | Subject          | select | Biology, Maths, Physics |
            | Booking date     | date   |                         |
            | Name             | text   |                         |
            | Telephone number | tel    |                         |
            | Email address    | email  |                         |

    Scenario: Updating and submitting a new booking
        Given I am on the 'make changes' page for the placement request
        And I enter a future date in the 'Booking date' date field
        And I select 'Biology' from the 'Subject' select box
        And I have entered the following details into the form:
            | Name             | Joey Test     |
            | Telephone number | 01234 456 421 |
            | Email address    | test@test.org |
        When I submit the form
        Then I should be on the 'preview confirmation email' page for the placement request
        And the booking details should have been saved
