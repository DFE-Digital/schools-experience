Feature: Updating a date
    To allow me to better organise my school experience days
    As a school administrator
    I want to be able to re-arrange placements

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded
        And the scheduled booking date is in the future

    Scenario: Page title
        Given there is at least one booking
        When I am on the 'change booking date' page for my booking
        Then the page title should be 'Change booking date'

    Scenario: Back link
        Given there is at least one booking
        When I am on the 'change booking date' page for my booking
        Then I should see a 'Back' link to the show page for my booking

    Scenario: Form contents
        Given there is at least one booking
        When I am on the 'change booking date' page for my booking
        Then I should see a form with the following fields:
            | Label        | Type |
            | Booking date | date |

    Scenario: When validation fails
        Given there is at least one booking
        And I am on the 'change booking date' page for my booking
        When I change the date to an invalid date
        And I submit the form
        Then I should see the validation error 'Enter a valid date'

    Scenario: Changing a date
        Given there is at least one booking
        And I am on the 'change booking date' page for my booking
        When I change the date to one two weeks in the future
        And I submit the form
        Then I should be on the date changed confirmation page
        And the date should have been updated

    Scenario: Date changed confirmation screen
        Given I have changed a booking date
        When I should be on the date changed confirmation page
        Then I should see a 'The school experience booking date has been updated' confirmation
        And the page should contain the new booking date
        And I should see a 'Return to bookings' link to the 'bookings'
