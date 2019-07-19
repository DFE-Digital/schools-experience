Feature: Entering teaching preference details
    So I can inform the school about my teaching preferences
    As a potential candidate
    I want to enter some details about my teacing preferences

    Background:
        Given my school of choice exists
        And the school offers 'Mathematics, Physics'

    Scenario: Filling in and submitting the form with errors
        Given I have completed the personal information form
        And I have completed the contact information form
        And I have completed the education form
        And I am on the 'teaching preference' page for my school of choice
        When I submit the form
        Then I should see the validation error 'Select a teaching stage'
        And I should see the validation error 'Select a subject'

    Scenario: Filling in and subject the form
        Given I have completed the personal information form
        And I have completed the contact information form
        And I have completed the education form
        And I am on the 'teaching preference' page for my school of choice
        And I make my teaching preference selection
        When I submit the form
        Then I should be on the 'request school experience placement' page for my school of choice

    Scenario: Editing choices
        Given I have completed the wizard
        And I am on the 'edit teaching preference' page for my school of choice
        And I change my teaching subject
        When I submit the form
        Then I should be on the 'check your answers' page for my school of choice
