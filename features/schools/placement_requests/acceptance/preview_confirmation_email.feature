Feature: Accepting placement requests
    So I can assist candidates who have applied at my school
    As a school administrator
    I want to be able to preview the booking confirmation email

    Background:
        Given I am logged in as a DfE user
        And the subjects 'Biology' and 'Chemistry' exist
        And there is a new placement request
        And I have completed the 'confirm booking' page
        And I have completed the 'add more details' page
        And I have completed the 'review and send email' page

    Scenario: Page title
        Given I have progressed to the 'preview confirmation email' page for my chosen placement request
        Then the page title should be 'Send details to candidate'

    Scenario: Page contents
        Given I have progressed to the 'preview confirmation email' page for my chosen placement request
        Then I should see an email preview with the following subheadings:
            | School details                |
            | School experience contacts    |
            | School experience details     |
            | Help and support              |

    Scenario: Email preview - school details
        Given I have progressed to the 'preview confirmation email' page for my chosen placement request
        Then in the 'School details' section I should see the following items:
            | School or college |
            | Address           |
            | Dress code        |
            | Parking           |
        And the school details section should contain the relevant information

    Scenario: Email preview - school experience contacts
        Given I have progressed to the 'preview confirmation email' page for my chosen placement request
        Then in the 'School experience contacts' section I should see the following items:
            | Name                |
            | Email address       |
            | UK telephone number |
        And the school experience contacts section should contain the relevant information

    Scenario: Email preview - school experience details
        Given I have progressed to the 'preview confirmation email' page for my chosen placement request
        Then in the 'School experience details' section I should see the following items:
            | Subject                           |
            | Experience details                |
        And the school experience details section should contain the relevant information

    Scenario: Email preview - help and support
        Given I have progressed to the 'preview confirmation email' page for my chosen placement request
        Then in the 'Help and support' section I should see the following items:
            | Name                |
            | Email address       |
            | UK telephone number |
        And the help and support section should contain the relevant information

    Scenario: Email preview - extra details from the school
        Given I have progressed to the 'preview confirmation email' page for my chosen placement request
        Then the extra details from the school section should contain the relevant information

    Scenario: Sending the email
        Given I have progressed to the 'preview confirmation email' page for my chosen placement request
        And I think the email looks good
        When I click the 'Send confirmation email' button
        Then I should be on the 'email sent' page for my chosen placement request
        And the placement request should be accepted
