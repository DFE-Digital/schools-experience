Feature: Entering candidate subject preference details
    So I can inform the school about my education and expertise
    As a potential candidate
    I want to enter some details about my degree and preferred subjects

    Background:
        Given there are some subjects

    @wip
    Scenario: Form contents
        Given I am on the 'candidate subjects' page for my school of choice
        Then I should see radio buttons for 'What stage are you at with your degree' with the following options:
            | I don't have a degree and am not studying for one |
            | Graduate or postgraduate                          |
            | Final year                                        |
            | Second year                                       |
            | First year                                        |
            | Other                                             |
        And I should see a select box containing degree subjects labelled 'If you have or are studying for a degree, tell us about your degree subject'
        And I should see radio buttons for 'Which of the following teaching stages are you at?' with the following options:
            | I'm thinking about teaching and want to find out more |
            | I want to become a teacher                            |
            | I've applied for teacher training                     |
            | I've been accepted on teacher training                |
        And I should see a select box containing school subjects labelled 'First choice'
        And I should see a select box containing school subjects labelled 'Second choice'

    @wip
    Scenario: Filling in and submitting the form
        Given I am on the 'candidate subjects' page for my school of choice
        And I make my degree and teaching preference selections
        When I submit the form
        Then I should be on the 'background checks' page for my school of choice

    @javascript
    Scenario: Hiding degree subject choice when candidate has no degree
        Given I am on the 'candidate subjects' page for my school of choice
        When I choose 'I don\'t have a degree and am not studying for one' as my degree stage
        Then I should not see any subject choices

    @javascript
    Scenario: Showing degree subject choice when candidate has a degree
        Given I am on the 'candidate subjects' page for my school of choice
        When I choose 'Final year' as my degree stage
        Then I should see some subject choices
