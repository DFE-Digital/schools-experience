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

    Scenario: List contents
        Given there are some bookings
        When I am on the 'bookings' page
        Then the bookings should have the following values:
			| Heading          | Value                             |
            | Dates requested  | Any time during July 2019         |
            | Request received | 01 January 2019                   |
            | Contact details  | View contact details              |
            | Teaching stage   | I've applied for teacher training |
            | Teaching subject | Maths                             |
            | Status           | New                               |

    @javascript
    Scenario: Expanding the contact details
        Given there are some bookings
        And I am on the 'bookings' page
        When I click 'View contact details' on the first booking
        Then I should see the following contact details for the first booking:
			| Heading             | Value                           |
            | Address             | First Line, Manchester, MA1 1AM |
            | UK telephone number | 07123 456789                    |
            | Email address       | first@thisaddress.com           |

    Scenario: Open request buttons
        Given there are some bookings
        When I am on the 'bookings' page
        Then every booking should contain a link to view more details

    Scenario: List item titles
        Given there are some bookings
        When I am on the 'bookings' page
        Then every booking should contain a title starting with 'Booking by'
