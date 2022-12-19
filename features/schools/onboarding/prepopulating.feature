Feature: Prepopulating
  Background:
    Given the Task Based On-boarding feature is enabled
    And I am logged in as a DfE user

  Scenario: Page title
    Given I am on-boarding a new school
    And I am on the 'Progress' page
    Then the page title should be 'On-boarding Progress'

  Scenario: Prepopulating not available
    Given I am on-boarding a new school
    And I am on the 'Progress' page
    Then I should not see 'Select another school'

  Scenario: Prepopulating school profile
    And I am on-boarding a new school and have access to another school that is already on-boarded
    And I am on the 'Progress' page
    Then I should see the text 'You have completed 0 out of 5 sections'
    When I select 'Existing School' from the 'Select another school' select box
    And I click the 'Prepopulate' button
    Then I should see the text 'You have completed 5 out of 5 sections'
