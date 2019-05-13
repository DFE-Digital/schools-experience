Feature: Viewing all bookings
    To give me an oversight of booked placements
    As a school administrator
    I want to be able see a complete list of bookings

    Background:
        Given I am logged in as a DfE user

    Scenario: Page title
        Given I am on the 'bookings' page
        Then the page title should be 'All bookings'

    Scenario: Back link
        Given there are some bookings
        When I am on the 'bookings' page
        Then I should see a 'Back' link to the 'schools dashboard'

    Scenario: List presence
        Given there are some bookings
        When I am on the 'bookings' page
        Then I should see all the bookings listed

    Scenario: Table headings
        Given there are some bookings
        When I am on the 'bookings' page
        Then the bookings table should have the following values:
			| Heading | Value            |
            | Name    | Matthew Richards |
            | Subject | Biology          |
            | Date    | 02 October 2019  |

    Scenario: Open request buttons
        Given there are some bookings
        When I am on the 'bookings' page
        Then every booking should contain a link to view more details
