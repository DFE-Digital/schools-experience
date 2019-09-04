Feature: Editing placement dates
    So I can control availability on my school profile
    As a school administrator
    I want to be able to switch between flexible and fixed dates

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded
        And my school is set to use 'fixed' dates

    Scenario: Page title
        Given I am on the 'availability preferences' page
        Then the page title should be 'Choose how dates are displayed'

    Scenario: Breadcrumbs
        Given I am on the 'availability preferences' page
        Then I should see the following breadcrumbs:
            | Text                           | Link               |
            | Some school                    | /schools/dashboard |
            | Choose how dates are displayed | None               |

    Scenario: Page contents
        Given I am on the 'availability preferences' page
        Then I should see radio buttons for 'Choose how dates are displayed' with the following options:
            | Show specific dates                                |
            | Show a description of when you can host candidates |
        And the submit button should contain text 'Continue'

    Scenario: Submitting the form
        Given I am on the 'availability preferences' page
        When I choose "Show a description of when you can host candidates" from the "Choose how dates are displayed" radio buttons
        And I submit the form
        Then I should be on the 'schools dashboard' page
        And my school's availability preference should be 'fixed'
