Feature: Editing availability info
    So I can give candidates guidance when they are applying
    As a school administrator
    I want to be able to set my availability information text

    Background:
        Given I am logged in as a DfE user
        And my school is set to use 'flexible' dates
        And my school is fully-onboarded

    Scenario: Page title
        Given I am on the 'availability information' page
        Then the page title should be 'Describe when you’ll host school experience candidates'

    Scenario: Page contents
        Given I am on the 'availability information' page
        Then there should be a 'Describe your school experience availability' text area
        And I should see radio buttons for 'School experience type' with the following options:
            | Virtual experience                     |
            | In school experience                   |
            | Both virtual and in school experiences |
        And the submit button should contain text 'Save availability description'

    Scenario: Back link
        Given I am on the 'availability information' page
        Then I should see a 'Back' link to the 'availability preferences'

    @smoke_test
    Scenario: Submitting the form
        Given I am on the 'availability information' page
        When I enter 'Every third Tuesday' into the 'Describe your school experience availability' text area
        And I choose 'Virtual experience' from the "School experience type" radio buttons
        And I click the 'Save availability description' submit button
        Then I should be on the 'schools dashboard' page
        And my school's availabiltiy info should have been updated

    Scenario: Auto-enabling school
        Given my school is disabled
        And I am on the 'availability information' page
        When I enter 'Every third Tuesday' into the 'Describe your school experience availability' text area
        And I choose 'Virtual experience' from the "School experience type" radio buttons
        And I click the 'Save availability description' submit button
        Then my school should be enabled
