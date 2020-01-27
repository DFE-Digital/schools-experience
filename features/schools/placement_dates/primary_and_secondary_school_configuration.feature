Feature: Configuring a placement date
    So I can manage placement dates
    As an administrator of a combined primary and secondary school
    I want to be able to specify details about the dates we offer

  Background:
    Given I am logged in as a DfE user
    And my school is a 'primary and secondary' school
    And my school is fully-onboarded
    And I have entered a secondary placement date for a multi-phase school

  Scenario: Page title
    Then the page's main heading should be the date I just entered

  Scenario: Date is not subject specific
    When I choose 'General experience' from the "Select type of experience" radio buttons
    And I submit the form
    Then I should be on the 'placement dates' page
    And my newly-created placement date should be listed

  Scenario: Date is subject specific
    When I choose 'Specific to a subject' from the "Select type of experience" radio buttons
    And I submit the form
    Then I should be on the new subject selection page for this date
