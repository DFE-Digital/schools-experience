Feature: Viewing all placement requests
    To help me deal with requests for school experience
    As a school administrator
    I want to be able see a complete list of placement requests

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded
        And the school has subjects

    Scenario: Page title
        Given I am on the 'placement requests' page
        Then the page title should be 'Manage requests'

    Scenario: List presence
        Given there are some placement requests
        When I am on the 'placement requests' page
        Then I should see all the placement requests listed

    Scenario: Table contents
        Given there are some placement requests
        When I am on the 'placement requests' page
        Then I should see a table with the following headings:
            | Name                   |
            | Status                 |
            | Subjects               |
            | School experience date |

    Scenario: Open request buttons
        Given there are some placement requests
        When I am on the 'placement requests' page
        Then every request should contain a link to view more details

    Scenario: Unviewed placement requests
        Given there are some unviewed placement requests
        When I am on the 'placement requests' page
        Then the unviewed requests should have a status of 'New'

    Scenario: Viewed placement requests
        Given there are some viewed placement requests
        When I am on the 'placement requests' page
        Then the viewed requests should have no status

    Scenario: Placement requests from candidate who already had attended bookings
        Given there are placement requests from candidate who already had attended bookings
        When I am on the 'placement requests' page
        Then these requests should have a status of Flagged
