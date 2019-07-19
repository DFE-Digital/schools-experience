Feature: The school not registered error page
    So I know my school hasn't been registered with School Experience
    As an administrator from an unregistered school
    I want to see some informative instructions

    Background:
        Given I am logged in as a DfE user

    Scenario: Email address
        Given I am on the 'not registered error' page
        Then I should see a email link to 'organise.school-experience@education.gov.uk'

    Scenario: Page title
        Given I am on the 'not registered error' page
        Then the page title should be 'Error - your school is not signed up to the manage school experience service'

    Scenario: Change school link
        Given I am on the 'not registered error' page
        Then I should see a 'Change school' link to the 'change school' page

    Scenario: Context
        Given I am on the 'not registered error' page
        Then I should see my current school's name
        And I should see my name in the body of the page
