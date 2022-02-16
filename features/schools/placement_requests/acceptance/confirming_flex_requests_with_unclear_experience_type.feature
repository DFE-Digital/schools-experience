Feature: Confirming a flex request when experience type is  unclear
    So I can quickly set the experience type and accept a placement request
    As a school administrator
    I want to be able to choose the experience type and accept a booking in one step

    Background:
        Given I am logged in as a DfE user
        And the school has subjects
        And my school has flexible dates
        And there is a new placement request

    Scenario: Accepting a flexible booking with experience type 'both'
        Given I am on the 'confirm booking' page for the placement request
        When I click the 'Continue' button
        Then I should see a form with the following fields:
            | Label                  | Type   | Options             |
            | Booking date           | date   |                     |
            | Experience type        | radio  | In school, Virtual  |

    Scenario: Displaying experience type validation error when the request experience type 'both'
        Given I am on the 'make changes' page for the placement request
        And I enter a future date in the 'Booking date' date field
        When I submit the form
        Then I should see the validation error 'Select if it is an in school or virtual experience'

    @smoke_test
    Scenario: Updating and submitting a flexible booking with experience type 'both'
        Given I am on the 'make changes' page for the placement request
        And I enter a future date in the 'Booking date' date field
        And I select 'Biology' from the 'Subject' select box
        And I choose 'Virtual' from the 'Experience type' radio buttons
        And I have entered the following details into the form:
            | Name             | Joey Test     |
            | Telephone number | 01234 456 421 |
            | Email address    | test@test.org |
        When I submit the form
        Then I should be on the 'preview confirmation email' page for the placement request
        And the booking details should have been saved
