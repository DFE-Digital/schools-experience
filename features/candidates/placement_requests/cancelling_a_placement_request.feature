Feature: Cancelling a placement requests
  So I don't waste schools time
  As a potential candidate
  I want to be able to cancel placement requests I know I can't attend

  Scenario: Page contents
    Given I have made a placement request
    When I visit the cancellation link
    Then the page's main heading should be "Cancel request"
    And I should see a form to enter my cancellation reason

  Scenario: Submitting the form
    Given I have made a placement request
    And I visit the cancellation link
    And I have entered the following details into the form:
      | Cancellation reasons | Won the lottery, going on holiday |
    When I click the 'Cancel' button
    Then I should see the confirmation page for my cancelled 'request'
