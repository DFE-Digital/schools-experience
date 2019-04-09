Feature: Rejecting placement requests
    So I can inform unsuitable candidates why they have been rejected
    As a school administrator
    I want to be able to reject placement requests

    Background:
        Given I am logged in

    Scenario: Back link
        Given there are some upcoming requests
        When I am on the 'upcoming requests' page
        Then I should see a 'Back' link to the 'schools dashboard'

    Scenario: Page heading
        Given there is at least once placement request
        When I am on the 'reject placement request' page
        Then the page's main heading should be 'Reject request'

    Scenario: Reject information
        Given there is at least once placement request
        And the candidate's name is "Robert Terwilliger"
        When I am on the 'reject placement request' page
        Then the following text should be present:
        """
        Enter and confirm the reasons for rejecting the school experience request by Robert Terwilliger.
        """

    Scenario: Reject information
        Given there is at least once placement request
        When I am on the 'reject placement request' page
        Then the following text should be present:
        """
        The reasons you enter will be sent to them in an email confirmation to let them know why their request has been turned down.
        """

    Scenario: Reject form
        Given there is at least once placement request
        When I am on the 'reject placement request' page
        Then there should be a 'Reason' text area
        And the submit button should contain text 'Reject request'
