Feature: Rejecting placement requests
    So I can inform unsuitable candidates why they have been rejected
    As a school administrator
    I want to be able to reject placement requests

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded
        And the school has subjects

    Scenario: Back link
        Given there is at least one placement request
        And there are some upcoming requests
        When I am on the reject placement request page
        Then I should see a 'Back' link to the 'placement requests' page

    Scenario: Page heading
        Given there is at least one placement request
        When I am on the reject placement request page
        Then the page's main heading should be 'Review and send rejection email to candidate'

    Scenario: Reject information
        Given there is at least one placement request
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
        Then I should see radio buttons for 'Rejection reason' with the following options:
            | The date you requested is fully booked                                                                    |
            | We cannot offer you school experience because you have already been accepted on a Teacher Training Course |
            | We cannot support the date you have requested                                                             |
            | We do not believe you have a relevant degree for the school experience you are applying for               |
            | We are unable to offer you school experience for the teaching phase you are interested in                 |
            | We are looking for candidates that live locally to the school                                             |
            | This is a duplicate request                                                                               |
            | Other                                                                                                     |
        And there should be a 'Extra details' text area
        And the submit button should contain text 'Preview rejection email'

    Scenario: Rejecting the requests
        Given there is at least one placement request
        And I am on the reject placement request page
        And I choose 'We cannot support the date you have requested' from the 'Rejection reason' radio buttons
        And I have entered a extra details in the extra details text area
        When I click the 'Preview rejection email' button
        Then I should see a preview of what I have entered

    @javascript
    Scenario: Entering a custom option
        Given there is at least one placement request
        And I am on the reject placement request page
        And I choose 'Other' from the 'Rejection reason' radio buttons
        Then a text area labelled 'Cancellation reasons' should have appeared

    @javascript
    Scenario: Rejecting the requests with a custom reason
        Given there is at least one placement request
        And I am on the reject placement request page
        And I choose 'Other' from the 'Rejection reason' radio buttons
		And I enter 'The school will be closed' into the 'Cancellation reasons' text area
        When I click the 'Preview rejection email' button
        Then I should see my custom cancellation reason
