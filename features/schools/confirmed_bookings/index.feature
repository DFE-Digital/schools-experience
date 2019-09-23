Feature: Viewing all bookings
    To give me an oversight of booked placements
    As a school administrator
    I want to be able see a complete list of bookings

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded

    Scenario: Page title
        Given I am on the 'bookings' page
        Then the page title should be 'Manage bookings'

    Scenario: Breadcrumbs
        Given I am on the 'bookings' page
        Then I should see the following breadcrumbs:
            | Text            | Link               |
            | Some school     | /schools/dashboard |
            | Manage bookings | None               |

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
        And the booking date should be correct

    Scenario: Only viewing current school's bookings
        Given there are some bookings
        And there are some bookings belonging to other schools
        When I am on the 'bookings' page
        Then I should only see bookings belonging to my school

    Scenario: Open request buttons
        Given there are some bookings
        When I am on the 'bookings' page
        Then every booking should contain a link to view more details

    Scenario:
        Given there are no bookings
        When I am on the 'bookings' page
        Then I should see the text 'There are no upcoming bookings'
        And I should not see the bookings table
