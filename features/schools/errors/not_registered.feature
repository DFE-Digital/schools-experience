Feature: The school not registered error page
    So I know my school hasn't been registered with School Experience
    As an administrator from an unregistered school
    I want to see some informative instructions

    Scenario: Email address
        Given I am on the 'not registered error' page
        Then I should see a email link to 'organise.school-experience@education.gov.uk'

    Scenario: Change school link
        Given I am on the 'not registered error' page
        Then I should see a 'Change school' link to the 'change school' page
