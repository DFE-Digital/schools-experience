Feature: Editing placement dates
    So I can manage placement dates
    As a school administrator
    I want to be able to update and delete records

    Background:
        Given I am logged in as a DfE user

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
        And there should be a 'Make this date available to candidates?' checkbox

    Scenario: Filling in and submitting the form
        Given I am on the edit page for my placement
        And I fill in the form with a future date and duration of 6
        When I submit the form
        Then I should be on the 'placement dates' page
        And my newly-created placement date should be listed

    Scenario: Activating a placement date
        Given I am on the edit page for my 'inactive' placement
        When I check the 'Make this date available to candidates?' checkbox
        And I submit the form
        Then I should be on the 'placement dates' page
        And my placement should have been 'activated'

    Scenario: Deactivating a placement date
        Given I am on the edit page for my 'active' placement
        When I uncheck the 'Make this date available to candidates?' checkbox
        And I submit the form
        Then I should be on the 'placement dates' page
        And my placement should have been 'deactivated'
