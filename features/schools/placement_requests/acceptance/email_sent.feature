Feature: Viewing my sent receipt
    So I can be confident that my email has been sent
    As a school administrator
    I want to see a receipt stating that it was successful

    Background:
        Given I am logged in as a DfE user
        And the subjects 'Biology' and 'Chemistry' exist
        And there is a new placement request
        And I have completed the 'confirm booking' page
        And I have completed the 'add more details' page
        And I have completed the 'review and send email' page
        And I have completed the 'preview confirmation email' page

    Scenario: Page contents
        Given I have progressed to the 'email sent' page for my chosen placement request
        Then I should see a panel stating 'Your email has been sent'
        And there should be a 'Return to requests and bookings' link to the 'schools dashboard'
