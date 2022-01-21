Feature: Request a school experience placement
    So I can register my interest in a placement with a school
    As a potential candidate
    I want to submit my details to the school

    Background:
       Given my school of choice exists
       And the school offers 'Physics, Mathematics'
       And I have completed the personal information form
       And I have completed the contact information form
       And I have completed the education form
       And I have completed the teaching preference form

    Scenario: Page title and description
        Given I am on the 'Request school experience placement' page for my school of choice
        Then the page's main header should be 'Request school experience'

    Scenario: Displaying a warning if the school has availability information
        Given my school has availability information set
        When I am on the 'Request school experience placement' page for my school of choice
        Then I should see a warning containing the availability information

    Scenario: No warning should be displayed if the availability information is absent
        Given my school has availability no information set
        When I am on the 'Request school experience placement' page for my school of choice
        Then I should see no warning containing the availability information

    @javascript
    Scenario: Word counting in placement objectives
        Given I am on the 'Request school experience placement' page for my school of choice
        Then the 'What do you want to get out of your school experience?' word count should say 'You have 150 words remaining'

    @javascript
    Scenario: Updating the word count in placement objectives
        Given I am on the 'Request school experience placement' page for my school of choice
        When I enter 'The quick brown fox' into the 'What do you want to get out of your school experience?' text area
        Then the 'What do you want to get out of your school experience?' word count should say 'You have 146 words remaining'

    @javascript
    Scenario: Word counting in placement objectives in availability
        Given I am on the 'Request school experience placement' page for my school of choice
        Then the 'Tell us about your availability' word count should say 'You have 150 words remaining'

    @javascript
    Scenario: Updating the word count in availability
        Given I am on the 'Request school experience placement' page for my school of choice
        When I enter 'The quick brown fox' into the 'Tell us about your availability' text area
        Then the 'Tell us about your availability' word count should say 'You have 146 words remaining'
