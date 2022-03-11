Feature: Reviewing recurrences for a placement date
  So I can manage placement dates
  As a school administrator
  I want to be able to review the recurring dates for a placement request

  Background:
    Given I am logged in as a DfE user
    And my school is fully-onboarded
    And I have entered a recurring placement date

  Scenario: Page title
    Given I select "Daily" recurrence and enter a valid date
    And I click the "Check dates and continue" button
    Then the page's main heading should be 'Review dates'

  Scenario: Daily recurrence
    Given I select "Daily" recurrence and enter a valid date
    And I click the "Check dates and continue" button
    Then I should see the "Daily" recurring dates
    And all recurring dates should be checked
    Then I click "Check dates and continue"
    And I should be on the "new placement details" page for my placement date

  Scenario: Weekly recurrence
    Given I select "Weekly" recurrence and enter a valid date
    And I click the "Check dates and continue" button
    Then I should see the "Weekly" recurring dates
    And all recurring dates should be checked
    Then I click "Check dates and continue"
    And I should be on the "new placement details" page for my placement date

  Scenario: Fortnightly recurrence
    Given I select "Fortnightly" recurrence and enter a valid date
    And I click the "Check dates and continue" button
    Then I should see the "Fortnightly" recurring dates
    And all recurring dates should be checked
    Then I click "Check dates and continue"
    And I should be on the "new placement details" page for my placement date

  Scenario: Custom recurrence
    Given I select "Custom" recurrence and enter a valid date
    And I click the "Check dates and continue" button
    Then I should see the "Custom" recurring dates
    And all recurring dates should be checked
    Then I click "Check dates and continue"
    And I should be on the "new placement details" page for my placement date
