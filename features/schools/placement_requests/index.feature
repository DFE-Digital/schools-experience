Feature: Viewing all placement requests
    To help me deal with requests for school experience
    As a school administrator
    I want to be able see a complete list of placement requests

    Background:
        Given I am logged in as a DfE user
        And the school has subjects

    Scenario: Page title
        Given I am on the 'placement requests' page
        Then the page title should be 'All placement requests'

    Scenario: Back link
        Given there are some placement requests
        When I am on the 'placement requests' page
        Then I should see a 'Back' link to the 'schools dashboard'

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
