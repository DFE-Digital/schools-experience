Feature: Configuring a placement date
    So I can manage placement dates
    As a secondary school administrator
    I want to be able to specify details about the dates we offer

  Background:
    Given I am logged in as a DfE user
    And my school is a 'secondary' school
    And my school is fully-onboarded
    And I have entered a placement date
    And I have entered placement details

  Scenario: Page contents
    Then the page's main heading should be "Select type of experience"
    And I should see a back link
    And the page title should be 'Set date options'

  # Disabled Javascript scenario which requires Selenium+javascript to run (incompatible with Alpine 3.21)
  @wip
  Scenario: Select no max number of bookings
    When I choose 'No' from the "Is there a maximum number of bookings you’ll accept for this date?" radio buttons
    Then there is no 'Enter maximum number of bookings' text area

  # Disabled Javascript scenario which requires Selenium+javascript to run (incompatible with Alpine 3.21)
  @wip
  Scenario: Select max number of bookings
    When I choose 'Yes' from the "Is there a maximum number of bookings you’ll accept for this date?" radio buttons
    Then there should be a 'Enter maximum number of bookings.' number field

  @smoke_test
  Scenario: Date is not subject specific
    When I choose 'No' from the "Is there a maximum number of bookings you’ll accept for this date?" radio buttons
    And I choose 'General experience' from the "Select type of experience" radio buttons
    And I submit the form
    Then I should be on the 'new publish dates' page for my placement date
    And I click the "Publish placement date" button
    Then I should be on the 'placement dates' page
    And my newly-created placement date should be listed

  Scenario: Date is subject specific
    Given I choose 'No' from the "Is there a maximum number of bookings you’ll accept for this date?" radio buttons
    And I choose 'Specific to a subject' from the "Select type of experience" radio buttons
    When I submit the form
    Then I should be on the "new subject selection" page for my placement date
