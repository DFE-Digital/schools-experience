Feature: Experience preference
    So I can inform a school of what I want to get from a placement
    As a potential candidate
    I want to be able to enter my expectations

    Background:
        Given my school of choice exists
        And the school offers 'Physics, Mathematics'
        And I have completed the personal information form
        And I have completed the contact information form
        And I have completed the education form (select)
        And I have completed the teaching preference form

    Scenario: Page title and description
        Given I am on the 'Placement preference' page for my school of choice
        Then the page's main header should be 'What do you want to get out of your school experience?'

    Scenario: Form contents
        Given I am on the 'Placement preference' page for my school of choice
        Then there should be a 'Enter what you want to get out of your placement' text area

    @javascript
    Scenario: Word counting in placement objectives
        Given I am on the 'Placement preference' page for my school of choice
        Then the 'Enter what you want to get out of your placement' word count should say 'You have 150 words remaining'

    @javascript
    Scenario: Updating the word count in placement objectives
        Given I am on the 'Placement preference' page for my school of choice
        When I enter 'The quick brown fox' into the 'Enter what you want to get out of your placement' text area
        Then the 'Enter what you want to get out of your placement' word count should say 'You have 146 words remaining'
