Feature: Listing placement dates
    So I can manage my placement dates
    As a school administrator
    I want an overview of existing dates

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded

    Scenario: Page title
        Given I am on the 'placement dates' page
        Then the page title should be 'Manage dates'

  Scenario: Breadcrumbs
    Given I am on the 'placement dates' page
    Then I should see the following breadcrumbs:
        | Text         | Link               |
        | Some school  | /schools/dashboard |
        | Manage dates | None               |

    Scenario: List contents
        Given my school has 5 placement dates
        When I am on the 'placement dates' page
        Then I should see a list with 5 entries

    Scenario: List contents
        Given my school has a placement date
        When I am on the 'placement dates' page
        Then I should my placement date listed
        And it should include a 'Change' link to the edit page

    Scenario: The add a new placement date button
        Given I am on the 'placement dates' page
        Then there should be a 'Add dates' link to the new placement date page

    Scenario: Warning displayed when there are no dates
        Given my school has no placement dates
        When I am on the 'placement dates' page
        Then there should be a 'You haven't entered any dates, your school will not appear in candidate searches' warning

    Scenario: The return to dashboard button
        Given I am on the 'placement dates' page
        Then there should be a 'Return to dashboard' link to the 'schools dashboard'
