Feature: Entering candidate education details
    So I can inform the school about my education and expertise
    As a potential candidate
    I want to enter some details about my degree and preferred subjects

    Background:
       Given my school of choice exists
       And the school offers 'Physics, Mathematics'
       And I have completed the personal information form
       And I have completed the contact information form

    Scenario: Filling in and submitting the form with errors
        Given I am on the 'education' page for my school of choice
        When I submit the form
        Then I should see the validation error 'Select a degree stage'
        And I should see the validation error 'Select a subject'
        Given I am on the 'education' page for my school of choice
        And I choose 'Other' as my degree stage
        When I submit the form
        Then I should see the validation error 'Enter an explaination'

    Scenario: Filling in and submitting the form
        Given I am on the 'education' page for my school of choice
        And I make my degree selection
        When I submit the form
        Then I should be on the 'teaching preference' page for my school of choice

    @javascript
    Scenario: Hiding degree subject choice when candidate has no degree
        Given I am on the 'education' page for my school of choice
        When I choose 'I don\'t have a degree and am not studying for one' as my degree stage
        Then I should not see any subject choices

    @javascript
    Scenario: Showing degree subject choice when candidate has a degree
        Given I am on the 'education' page for my school of choice
        When I choose 'Final year' as my degree stage
        Then I should see some subject choices

    Scenario: Editing choices
        Given I have completed the wizard
        And I have completed the Education step
        And I am on the 'edit education' page for my school of choice
        And I change my degree selection
        When I submit the form
        Then I should be on the 'check your answers' page for my school of choice
