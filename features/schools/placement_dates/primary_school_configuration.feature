# this feature is awaiting capping, until then there is no configuration
# for primary dates
@wip
Feature: Configuring a placement date
    So I can manage placement dates
    As a primary school administrator
    I want to be able to specify details about the dates we offer

  Background:
    Given I am logged in as a DfE user
    And my school is a 'primary' school
    And my school is fully-onboarded

  Scenario: Page title
    Given I have entered a placement date
    Then the page's main heading should be the date I just entered

  @javascript
  Scenario: Select no max number of bookings
    Given I have entered a placement date
    When I choose 'No' from the "Is there a maximum number of bookings you’ll accept for this date?" radio buttons
    Then there is no 'Enter maximum number of bookings' text area

  @javascript
  Scenario: Select max number of bookings
    Given I have entered a placement date
    When I choose 'Yes' from the "Is there a maximum number of bookings you’ll accept for this date?" radio buttons
    Then there should be a 'Enter maximum number of bookings.' number field

  Scenario: The form shouldn't prompt for subject specicifity
    Given I have entered a placement date
    Then there should be no "Is this date available for all the subjects you offer?" field

  Scenario: Submitting the form
    Given I have entered a placement date
    When I choose 'No' from the "Is there a maximum number of bookings you’ll accept for this date?" radio buttons
    And I submit the form
    Then I should be on the 'placement dates' page
