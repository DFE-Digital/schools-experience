Feature: Cancelling bookings
    So I can react to unforseen circumstances
    As a school administrator
    I want to be able to cancel bookings

    Background:
        Given I am logged in as a DfE user
        And the school has subjects

    Scenario: Page heading
        Given there is at least one booking
        When I am on the cancel booking page
        Then the page's main heading should be 'Review and send cancellation email to candidate'

    Scenario: Reject information
        Given there is at least one booking
        When I am on the cancel booking page
        Then the following text should be present:
        """
        Dear Matthew Richards
        """
        And the following text should be present:
        """
        has cancelled your school experience booking for the following dates:
        """

    Scenario: Reject information
        Given there is at least one booking
        When I am on the cancel booking page
        Then the following text should be present:
        """
        Review the following email which will be sent to the candidate. You can add extra details.
        """

    Scenario: Reject form
        Given there is at least one booking
        When I am on the cancel booking page
        Then there should be a 'Cancellation reasons' text area
        And there should be a 'Extra details' text area
        And the submit button should contain text 'Preview cancellation email'

    Scenario: Rejecting the requests
        Given there is at least one booking
        And I am on the cancel booking page
        And I have entered a reason in the cancellation reasons text area
        And I have entered a extra details in the extra details text area
        When I click the 'Preview cancellation email' button
        Then I should see a preview of what I have entered

    Scenario: Sending the email
        Given I have progressed to the cancellation email preview page
        When I click the 'Send cancellation email' submit button
        Then I should see a 'Your cancellation email has been sent' confirmation
        And the page title should be 'Your cancellation email has been sent'
