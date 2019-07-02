Feature: Entering teaching preference details
    So I can inform the school about my teaching preferences
    As a potential candidate
    I want to enter some details about my teacing preferences

    Background:
        Given my school of choice exists
        And the school offers 'Mathematics, Physics'
        And I am on the 'teaching preference' page for my school of choice

    Scenario: Filling in and submitting the form with errors
        When I submit the form
        Then I should see the validation error 'Select a teaching stage'
        And I should see the validation error 'Select a subject'

    Scenario: Filling in and subject the form
        Given I make my teaching preference selection
        When I submit the form
        Then I should be on the 'candidate subjects' page for my school of choice

    Scenario: Editing choices
        Given I have completed the wizard
        And I have completed the Teaching preference step
        And I am on the 'edit teaching preference' page for my school of choice
        And I change my teaching subject
        When I submit the form
        Then I should be on the 'check your answers' page for my school of choice
