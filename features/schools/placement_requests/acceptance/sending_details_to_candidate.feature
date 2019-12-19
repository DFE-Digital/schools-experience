Feature: Previewing candidate emails
    So I can allow candidates to visit my school
    As a school administrator
    I want to be able to inform them about what they can expect and what
    they'll need on the day

    Background:
        Given I am logged in as a DfE user
        And the school has subjects
        And there is a new placement request with a future date

    Scenario: Page contents
        Given I am have progressed to the 'preview confirmation email' page for the placement request
        Then I should see an email preview that has the following sections:
            | School details             |
            | School experience contacts |
            | School experience details  |
            | Help and support           |

    Scenario: Actually confirming a placement request
        Given I am have progressed to the 'preview confirmation email' page for the placement request
        And I enter 'Come to the main reception' into the 'Extra instructions for the candidate' text area
        When I click the 'Send confirmation email' button
        Then I should be on the 'email sent' page for the placement request
        And the placement request should be accepted
        And I should be on the 'email sent' page for the placement request

    Scenario: Failing to send a placement request
        Given I am have progressed to the 'preview confirmation email' page for the placement request
        And I enter nothing into the 'Extra instructions for the candidate' text area
        When I click the 'Send confirmation email' button
        Then I should see an error
