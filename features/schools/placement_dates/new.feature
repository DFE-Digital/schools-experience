Feature: Creating new placement dates
    So I can add placement dates
    As a school administrator
    I want to be able to specify and create dates

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded

    Scenario: Page title
        Given I am on the 'new placement date' page
        Then the page title should be 'Add a date'

    Scenario: Placement date form
        Given I am on the 'new placement date' page
        Then I should see a form with the following fields:
            | Label                       | Type   |
            | Enter placement start date  | date   |

    Scenario: Preventing invalid dates from being added
        Given I am on the 'new placement date' page
        And I fill in the 'Enter placement start date' date field with an invalid date of 31st September next year
        When I submit the form
        Then I should see an error message stating 'Enter a start date'
        And my school should be disabled

    Scenario: Filling in and submitting the form
        Given I am on the 'new placement date' page
        When I fill in the form with a future date
        And I submit the form
        Then I should be on the new placement details page for my placement date
