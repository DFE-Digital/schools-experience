Feature: Selecting recurrence details for a placement date
  So I can manage placement dates
  As a school administrator
  I want to be able to specify how a placement date will recur

  Background:
    Given I am logged in as a DfE user
    And my school is fully-onboarded
    And I have entered a recurring placement date

  Scenario: Page title
    Then the page's main heading should be 'How often do you want this event to recur?'

  Scenario: Failing validation
    When I click the "Check dates and continue" button
    Then I should see an error message stating "Select how often you want this date to recur"
    Then I should see an error message stating "Enter the last date of the recurrence"
    Then I choose "Custom" from the "How often do you want this event to recur?" radio buttons
    When I click the "Check dates and continue" button
    Then I should see an error message stating "Select custom recurrence days"
    When I fill in the date field "Enter last date of the recurrence" with 10-10-2050
    And I click the "Check dates and continue" button
    Then I should see an error message stating "Last date of recurrence must 4 months or less after the first date"
    When I fill in the date field "Enter last date of the recurrence" with 10-10-2010
    And I click the "Check dates and continue" button
    Then I should see an error message stating "Last date of recurrence must be after the first date"

  Scenario: Daily recurrence
    Given I select "Daily" recurrence and enter a valid date
    And I click the "Check dates and continue" button
    Then I should be on the "new review recurrences" page for my placement date

  Scenario: Weekly recurrence
    Given I select "Weekly" recurrence and enter a valid date
    And I click the "Check dates and continue" button
    Then I should be on the "new review recurrences" page for my placement date

  Scenario: Fortnightly recurrence
    Given I select "Fortnightly" recurrence and enter a valid date
    And I click the "Check dates and continue" button
    Then I should be on the "new review recurrences" page for my placement date

  Scenario: Custom recurrence
    Given I select "Custom" recurrence and enter a valid date
    When I click the "Check dates and continue" button
    Then I should be on the "new review recurrences" page for my placement date
