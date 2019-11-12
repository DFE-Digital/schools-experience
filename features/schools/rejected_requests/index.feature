Feature: Viewing rejected requests
    To give me an view of the requests which have been cancelled by the school
    As a school administrator
    I want to be able see a complete list of rejected requests

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded
        And it has 'fixed' availability

    Scenario: Page title
        Given I am on the 'rejected requests' page
        Then the page title should be 'Rejected requests'

    Scenario: Breadcrumbs
        Given I am on the 'rejected requests' page
        Then I should see the following breadcrumbs:
            | Text               | Link               |
            | Some school        | /schools/dashboard |
            | Rejected requests | None               |

    Scenario: List presence
        Given there are some rejected requests
        When I am on the 'rejected requests' page
        Then I should see the rejected requests listed

    Scenario: Table headings
        Given there are some rejected requests
        When I am on the 'rejected requests' page
        Then the 'rejected-requests' table should have the following values:
			| Heading | Value            |
            | Name    | Matthew Richards |
            | Subject | Not specified    |
        And the rejected requests date should be correct

    Scenario: Only viewing current school's requests
        Given there are some rejected requests
        And there are some rejected requests belonging to other schools
        When I am on the 'rejected requests' page
        Then I should only see rejected requests belonging to my school

    Scenario: Open request links
        Given there are some rejected requests
        When I am on the 'rejected requests' page
        Then every rejected request should contain a link to view more details

    Scenario:
        Given there are no rejected requests
        When I am on the 'rejected requests' page
        Then I should see the text 'There are no rejected requests'
        And I should not see the requests table
