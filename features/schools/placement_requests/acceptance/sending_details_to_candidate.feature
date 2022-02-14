Feature: Previewing candidate emails
    So I can allow candidates to visit my school
    As a school administrator
    I want to be able to inform them about what they can expect and what
    they'll need on the day

    Background:
        Given I am logged in as a DfE user
        And the school has subjects
        And there is a new placement request with a future date

    Scenario: Page contents for in-school experience
        Given I have progressed to the 'preview confirmation email' page for the 'inschool' placement request
        Then I should see an email preview that has the following sections:
            | Date and time                     |
            | Location                          |
            | What to wear                      |
            | Who to report to when you arrive  |
            | About your school experience      |
            | Cancelling your booking           |
            | Help and support                  |

    Scenario: Page contents for virtual experience
        Given there is a new virtual placement request with a future date
        And I have progressed to the 'preview confirmation email' page for the 'virtual' placement request
        Then I should see an email preview that has the following sections:
            | Date and time                     |
            | Location                          |
            | Subject                           |
            | Who to contact                    |
            | Cancelling your booking           |

    @smoke_test
    Scenario: Actually confirming a placement request
        Given I have progressed to the 'preview confirmation email' page for the 'inschool' placement request
        And I enter 'Come to the main reception' into the 'Other instructions' text area
        When I click the 'Send confirmation email' button
        Then I should be on the 'email sent' page for the placement request
        And the placement request should be accepted
        And I should be on the 'email sent' page for the placement request

    Scenario: Failing to send a placement request
        Given I have progressed to the 'preview confirmation email' page for the 'inschool' placement request
        And I enter nothing into the 'Extra instructions for the candidate' text area
        When I click the 'Send confirmation email' button
        Then I should see an error
