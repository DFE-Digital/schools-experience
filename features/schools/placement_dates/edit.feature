Feature: Editing placement dates
    So I can manage placement dates
    As a school administrator
    I want to be able to update and delete records

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded

    Scenario: Page title
        Given I am on the edit page for my placement
        Then the page title should be 'Placement details'

    Scenario: Placement date form
        Given I am on the edit page for my placement
        Then I should see a form with the following fields:
            | Label                  | Type   |
            | How long will it last? | number |
            | When do you want to close this date to candidates? | number |
            | When do you want to publish this date? | number |

    Scenario: Filling in and submitting the form
        Given I am on the edit page for my placement
        And I fill in the placement details form with a duration of 6
        When I submit the form
        Then I am on the 'placement dates' page
        And my newly-created placement date should be listed

    @smoke_test
    Scenario: Activating a placement date
        Given I am on the edit page for my 'inactive' placement
        And I submit the form
        Then I am on the 'placement dates' page
        And my placement should have been 'activated'
