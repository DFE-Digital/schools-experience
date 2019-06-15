Feature: Viewing upcoming bookings
    To give me an oversight of upcoming booked placements
    As a school administrator
    I want to be able see a complete list of bookings

    Background:
        Given I am logged in as a DfE user

    Scenario: Page title
        Given I am on the 'upcoming bookings' page
        Then the page title should be 'Upcoming bookings'

    Scenario: Breadcrumbs
        Given I am on the 'upcoming bookings' page
        Then I should see the following breadcrumbs:
            | Text              | Link               |
            | Some school       | /schools/dashboard |
            | All bookings      | /schools/bookings  |
            | Upcoming bookings | None               |

    Scenario: List presence
        Given there are some bookings
        When I am on the 'upcoming bookings' page
        Then I should see all the bookings listed

    Scenario: Only viewing current school's bookings
        Given there are some bookings
        And there are some bookings belonging to other schools
        When I am on the 'upcoming bookings' page
        Then I should only see bookings belonging to my school

    Scenario: Non-upcoming dates shouldn't be listed
        Given there are some bookings
        And there are some non-upcoming bookings
        When I am on the 'upcoming bookings' page
        Then the upcoming bookings should be listed
        And the non-upcoming bookings shouldn't

    Scenario: Table headings
        Given there are some bookings
        When I am on the 'upcoming bookings' page
        Then the bookings table should have the following values:
			| Heading | Value            |
            | Name    | Matthew Richards |
            | Subject | Biology          |
        And the booking date should be correct

    Scenario: Open request buttons
        Given there are some bookings
        When I am on the 'upcoming bookings' page
        Then every booking should contain a link to view more details
