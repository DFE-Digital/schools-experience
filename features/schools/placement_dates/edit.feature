Feature: Editing placement dates
    So I can manage placement dates
    As a school administrator
    I want to be able to update and delete records

    Background:
        Given I am logged in as a DfE user
        And my school has a profile

    Scenario: Page title
        Given I am on the edit page for my placement
        Then the page title should be 'Modify placement date'

    Scenario: Back link
        Given I am on the edit page for my placement
        Then I should see a 'Back' link to the 'placement dates' page

    Scenario: Placement date form
        Given I am on the edit page for my placement
        Then I should see a form with the following fields:
            | Label                       | Type   |
            | Enter a start date          | date   |
            | How many days will it last? | number |

    Scenario: Filling in and submitting the form
        Given I am on the edit page for my placement
        And I fill in the form with a future date and duration of 6
        When I submit the form
        Then I should be on the 'placement dates' page
        And my newly-created placement date should be listed

    Scenario: Deleting a placement date
        Given my school has 2 placement dates
        And I am on the edit page for my placement
        When I click the 'Delete' button
        Then I should be on the 'placement dates' page
        And my placement should have been deleted
