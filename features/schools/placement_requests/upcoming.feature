Feature: Upcoming placement requests
    To help me deal with requests for school experience
    As a school administrator
    I want to be able see a list of upcoming requests

    Background:
        Given the subjects 'Biology' and 'Chemistry' exist
        And I am logged in as a DfE user

    Scenario: Page title
        Given I am on the 'upcoming requests' page
        Then the page title should be 'Upcoming placement requests'

    Scenario: Back link
        Given there are some placement requests
        When I am on the 'upcoming requests' page
        Then I should see a 'Back' link to the 'schools dashboard'

    Scenario: List presence
        Given there are some placement requests
        When I am on the 'upcoming requests' page
        Then I should see all the placement requests listed

    Scenario: List contents
        Given there are some placement requests
        When I am on the 'upcoming requests' page
        Then the placement listings should have the following values:
			| Heading          | Value                 |
            | Dates requested  | Every second Thursday |
            | Contact details  | View contact details  |
            | Teaching stage   | It’s just an idea     |
            | Teaching subject | Biology               |

    @javascript
    Scenario: Expanding the contact details
        Given there are some placement requests
        And I am on the 'upcoming requests' page
        When I click 'View contact details' on the first request
        Then I should see the following contact details:
			| Heading             | Value                           |
            | Address             | First Line, Manchester, MA1 1AM |
            | UK telephone number | 07123 456789                    |
            | Email address       | first@thisaddress.com           |

    Scenario: Open request buttons
        Given there are some placement requests
        When I am on the 'upcoming requests' page
        Then every request should contain a link to view more details

    Scenario: List item titles
        Given there are some placement requests
        When I am on the 'upcoming requests' page
        Then every request should contain a title starting with 'Request from'
