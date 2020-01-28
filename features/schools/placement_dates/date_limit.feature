Feature: Selecting subjects for a placement date
    So I can manage placement dates
    As a school administrator
    I want to be able to specify the maximum bookings a date can accept

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded
        And my school is a 'secondary' school
        And I am on the 'new placement date' page
        And I fill in the form with a future date and duration of 3
        And I choose 'Limited spaces' from the 'Is there a limit on the number of spaces' radio buttons
        And I submit the form
        Then the page title should be 'Set date options'
        And I choose 'General experience' from the "Select type of experience" radio buttons
        And I submit the form

    Scenario: Page title
        Then the page's main heading should be 'Set booking limits for '

    Scenario: Selecting nothing
        When I submit the form
        Then I should see a validation error message

    Scenario: Entering a limit
        Given I enter '4' into the 'Enter maximum number of bookings' text field
        When I submit the form
        Then I should be on the 'placement dates' page
        And my date should be listed

    Scenario: Already-selected limit should be filled in
        Given I have previously set a limit
        When I try to edit the limit for my newly-created placement date
        Then the '???????' should be checked
