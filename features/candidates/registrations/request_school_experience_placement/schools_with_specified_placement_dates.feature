Feature: Request a school experience placement
    So I can inform a school of what I want to get from a placement
    As a potential candidate
    I want to be able to enter my expectations

    Background:
        Given my school of choice exists
        And the school offers 'Physics, Mathematics'
        And the school I'm applying to is not flexible on dates
        And I am on the 'choose a subject and date' screen for my chosen school
        And I have filled in my subject and date information successfully
        And I have completed the personal information form
        And I have completed the contact information form
        And I have completed the education form
        And I have completed the teaching preference form

    Scenario: Form contents
        Given I am on the 'Request school experience placement' page for my school of choice
        Then there should be a 'What do you want to get out of your school experience?' text area

    Scenario: Submitting my data
        Given I am on the 'Request school experience placement' page for my school of choice
        When I enter 'I just love teaching!' into the 'What do you want to get out of your school experience?' text area
        And I submit the form
        Then I should be on the 'Background checks' page for my school of choice
