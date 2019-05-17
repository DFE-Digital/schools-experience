Feature: Viewing upcoming bookings
    To give me an oversight of upcoming booked placements
    As a school administrator
    I want to be able see a complete list of bookings

    Background:
        Given I am logged in as a DfE user
        And the scheduled booking date is '02 October 2019'

    Scenario: Page title
        Given I am on the 'upcoming bookings' page
        Then the page title should be 'Upcoming bookings'

    Scenario: Breadcrumbs
        Given I am on the 'upcoming bookings' page
        Then I should see the following breadcrumbs:
            | Text              | Link              |
            | Some school       | /schools          |
            | All bookings      | /schools/bookings |
            | Upcoming bookings | None              |

    Scenario: List presence
        Given there are some bookings
        When I am on the 'upcoming bookings' page
        Then I should see all the bookings listed

    Scenario: Table headings
        Given there are some bookings
        When I am on the 'upcoming bookings' page
        Then the bookings table should have the following values:
			| Heading | Value            |
            | Name    | Matthew Richards |
            | Subject | Biology          |
            | Date    | 02 October 2019  |

    Scenario: Open request buttons
        Given there are some bookings
        When I am on the 'upcoming bookings' page
        Then every booking should contain a link to view more details
