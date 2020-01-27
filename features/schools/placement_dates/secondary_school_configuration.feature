Feature: Configuring a placement date
    So I can manage placement dates
    As a secondary school administrator
    I want to be able to specify details about the dates we offer

  Background:
    Given I am logged in as a DfE user
    And my school is a 'secondary' school
    And my school is fully-onboarded
    And I have entered a placement date

  Scenario: Page contents
    Then the page's main heading should be the date I just entered
    And I should see a back link
    And the page title should be 'Set date options'

  Scenario: Date is not subject specific
    And I choose 'General experience' from the "Select type of experience" radio buttons
    And I submit the form
    Then I should be on the 'placement dates' page
    And my newly-created placement date should be listed

  Scenario: Date is subject specific
    And I choose 'Specific to a subject' from the "Select type of experience" radio buttons
    When I submit the form
    Then I should be on the new subject selection page for this date
