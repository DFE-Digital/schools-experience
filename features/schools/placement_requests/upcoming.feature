Feature: Upcoming placement requests
    To help me deal with requests for school experience
    As a school administrator
    I want to be able see a list of upcoming requests

    Background:
        Given I am logged in as a DfE user

    Scenario: Page title
        Given I am on the 'upcoming requests' page
        Then the page title should be 'Upcoming placement requests'

    Scenario: Back link
        Given there are some upcoming requests
        When I am on the 'upcoming requests' page
        Then I should see a 'Back' link to the 'schools dashboard'

    Scenario: List presence
        Given there are some upcoming requests
        When I am on the 'upcoming requests' page
        Then I should see all the upcoming requests listed

    Scenario: List contents
        Given there are some upcoming requests
        When I am on the 'upcoming requests' page
        Then the placement listings should have the following values:
			| Heading          | Value                             |
            | Dates requested  | Any time during July 2019         |
            | Request received | 01 January 2019                   |
            | Contact details  | View contact details              |
            | Teaching stage   | I've applied for teacher training |
            | Teaching subject | Maths                             |
            | Status           | New                               |

    @javascript
    Scenario: Expanding the contact details
        Given there are some upcoming requests
        And I am on the 'upcoming requests' page
        When I click 'View contact details' on the first request
        Then I should see the following contact details:
			| Heading             | Value                           |
            | Address             | First Line, Manchester, MA1 1AM |
            | UK telephone number | 07123 456789                    |
            | Email address       | second@thisaddress.com          |

    Scenario: Open request buttons
        Given there are some upcoming requests
        When I am on the 'upcoming requests' page
        Then every request should contain a link to view more details

    Scenario: List item titles
        Given there are some upcoming requests
        When I am on the 'upcoming requests' page
        Then every request should contain a title starting with 'Request from'
