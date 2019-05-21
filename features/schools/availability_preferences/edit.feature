Feature: Editing placement dates
    So I can control availability on my school profile
    As a school administrator
    I want to be able to switch between flexible and fixed dates

    Background:
        Given I am logged in as a DfE user
        And my school is set to use 'fixed' dates

    Scenario: Page title
        Given I am on the 'availability preferences' page
        Then the page title should be 'Availability preference'

    Scenario: Breadcrumbs
        Given I am on the 'availability preferences' page
        Then I should see the following breadcrumbs:
            | Text                     | Link     |
            | Some school              | /schools |
            | Availability preference  | None     |

    Scenario: Page contents
        Given I am on the 'availability preferences' page
        Then I should see radio buttons for 'Choose your availability preference' with the following options:
            | Fixed dates    |
            | Flexible dates |
        And the submit button should contain text 'Continue'

    Scenario: Submitting the form
        Given I am on the 'availability preferences' page
        When I choose 'Flexible dates' from the 'Choose your availability preference' radio buttons
        And I submit the form
        Then I should be on the 'schools dashboard' page
        And my school's availability preference should be 'fixed'

    @javascript
    Scenario: Warning
        Given my school has 2 placement dates
        When I am on the 'availability preferences' page
        And I choose 'Flexible dates' from the 'Choose your availability preference' radio buttons
        Then there should be a hint stating "If you change your school to use flexible dates"
