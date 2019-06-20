Feature: Cancelling a booking
  So I don't waste the schools time
  As a potential candidate
  I want to be able to cancel bookings that I know I can't attend

  Background:
    Given I have a booking

  Scenario: Page contents
    When I visit the bookings cancellation link
    Then the page's main heading should be "Cancel booking"
    And I should see a form to enter my cancellation reason

  Scenario: Submitting the form
    Given I visit the bookings cancellation link
    And I have entered the following details into the form:
      | Cancellation reasons | Won the lottery, going on holiday |
    When I click the 'Cancel' button
    Then I should see the confirmation page for my cancelled 'booking'

  Scenario: Cancelling a cancelled booking
    Given I have a cancelled booking
    When I visit the cancellation link
    Then I should see the confirmation page for my cancelled 'booking'
