Feature: Availability preference
    So I can inform a school when I'd like to attend
    As a potential candidate
    I want to submit a description of my availability to the school

    Background:
        Given my school of choice exists
        And the school offers 'Physics, Mathematics'
        And I have completed the personal information form
        And I have completed the contact information form
        And I have completed the education form
        And I have completed the teaching preference form
        And I have completed the placement preference form
        And the school I'm applying to is flexible on dates

    Scenario: Page title and description
        Given I am on the 'Availability preference' page for my school of choice
        Then the page's main header should be 'When are you available for school experience?'

    Scenario: Displaying a warning if the school has availability information
        Given my school has availability information set
        When I am on the 'Availability preference' page for my school of choice
        Then I should see a warning containing the availability information

    Scenario: No warning should be displayed if the availability information is absent
        Given my school has no availability information set
        When I am on the 'Availability preference' page for my school of choice
        Then I should see no warning containing the availability information

    @javascript
    Scenario: Word counting in placement objectives
        Given I am on the 'Availability preference' page for my school of choice
        Then the 'Enter your availability' word count should say 'You have 150 words remaining'

    @javascript
    Scenario: Updating the word count in placement objectives
        Given I am on the 'Availability preference' page for my school of choice
        When I enter 'Mondays and Fridays' into the 'Enter your availability' text area
        Then the 'Enter your availability' word count should say 'You have 147 words remaining'
