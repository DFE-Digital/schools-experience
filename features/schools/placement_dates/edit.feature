Feature: Editing placement dates
    So I can manage placement dates
    As a school administrator
    I want to be able to update and delete records

    Background:
        Given I am logged in as a DfE user

    Scenario: Page title
        Given I am on the edit page for my placement
        Then the page title should be 'Modify placement date'

    Scenario: Breadcrumbs
        Given I am on the edit page for my placement
        Then I should see the following breadcrumbs:
            | Text                  | Link                     |
            | Some school           | /schools                 |
            | Placement dates       | /schools/placement_dates |
            | Modify placement date | None                     |

    Scenario: Placement date form
        Given I am on the edit page for my placement
        Then I should see a form with the following fields:
            | Label                       | Type   |
            | How many days will it last? | number |
        And there should be a 'Make this date available to candidates?' checkbox
        And the current start date should be present

    Scenario: Filling in and submitting the form
        Given I am on the edit page for my placement
        And I fill in the form with a duration of 6
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
