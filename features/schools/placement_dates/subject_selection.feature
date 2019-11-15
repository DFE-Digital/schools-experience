Feature: Selecting subjects for a placement date
    So I can manage placement dates
    As a school administrator
    I want to be able to specify which subjects are available on a given date

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded
        And my school is a 'secondary' school
        And the school has subjects
        And I have entered a placement date
        And the placement date is subject specific

    Scenario: Page title
        Then the page's main heading should be 'Select school experience subjects'

    Scenario: Page content
        Then I should see a list of subjects the school offers
        And an option to select all subjects

    Scenario: Selecting nothing
        When I submit the form
        Then I should see a validation error message

    Scenario: Selecting all subjects
        Given I check 'All subjects'
        When I submit the form
        Then I should be on the 'placement dates' page
        And my date should be listed

    Scenario: Selecting some subjects
        Given I check 'Maths'
        When I submit the form
        Then I should be on the 'placement dates' page
        And my date should be listed

    Scenario: Already-selected subjects should be checked
        Given I have previously selected 'Biology'
        When I try to edit the subjects for my newly-created placement date
        Then the 'Biology' checkbox should be checked
