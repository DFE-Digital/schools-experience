Feature: Viewing cancelled bookings
    To give me an oversight of cancelled booked placements
    As a school administrator
    I want to be able see a complete list of cancelled bookings

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded
        And the school has subjects

    Scenario: Page title
        Given I am on the 'cancelled bookings' page
        Then the page title should be 'Cancelled bookings'

    Scenario: Breadcrumbs
        Given I am on the 'cancelled bookings' page
        Then I should see the following breadcrumbs:
            | Text               | Link               |
            | Some school        | /schools/dashboard |
            | Cancelled bookings | None               |

    Scenario: List presence
        Given there are some cancelled bookings
        When I am on the 'cancelled bookings' page
        Then I should see the cancelled bookings listed

    Scenario: Table headings
        Given there are some cancelled bookings
        When I am on the 'cancelled bookings' page
        Then the 'bookings' table should have the following values:
            | Heading        | Value            |
            | Name           | Matthew Richards |
            | Subject        | Biology          |
            | Cancelled by   | School           |
            | Action         | View             |

    Scenario: Only viewing current school's bookings
        Given there are some cancelled bookings
        And there are some cancelled bookings belonging to other schools
        When I am on the 'cancelled bookings' page
        Then I should only see bookings belonging to my school

    Scenario: Open booking links
        Given there are some cancelled bookings
        When I am on the 'cancelled bookings' page
        Then every booking should contain a link to view cancelled booking details

    Scenario:
        Given there are no bookings
        When I am on the 'cancelled bookings' page
        Then I should see the text 'There are no cancelled bookings'
        And I should not see the bookings table
