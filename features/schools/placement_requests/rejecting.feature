Feature: Rejecting placement requests
    So I can inform unsuitable candidates why they have been rejected
    As a school administrator
    I want to be able to reject placement requests

    Background:
        Given I am logged in as a DfE user
        And the school has subjects

    Scenario: Back link
        Given there are some upcoming requests
        When I am on the 'upcoming requests' page
        Then I should see a 'Back' link to the 'schools dashboard'

    Scenario: Page heading
        Given there is at least one placement request
        When I am on the reject placement request page
        Then the page's main heading should be 'Review and send rejection email to candidate'

    Scenario: Reject information
        Given there is at least one placement request
        And the candidate's name is "Robert Terwilliger"
        When I am on the reject placement request page
        Then the following text should be present:
        """
        Dear Matthew Richards
        Some school has turned down your school experience request for the following dates:
        """

    Scenario: Reject information
        Given there is at least one placement request
        When I am on the reject placement request page
        Then the following text should be present:
        """
        Review the following email which will be sent to the candidate. You can add extra details.
        """

    Scenario: Reject form
        Given there is at least one placement request
        When I am on the reject placement request page
        Then there should be a 'Cancellation reasons' text area
        And the submit button should contain text 'Preview rejection email'
