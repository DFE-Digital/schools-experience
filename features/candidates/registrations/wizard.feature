Feature: Persisting registration information on navigating away
  So I can keep my place in the wizard
  As a potential candidate
  I want to be able to regain my place on a partially completed wizard

  Background:
    Given my school of choice exists
    And my school of choice offers 'Physics'
    And my school of choice offers 'Mathematics'

  Scenario: Returning to the wizard
    Given I have completed the personal information form
    And I have completed the contact information form
    And I have completed the subject preference form
    And I have completed the placement preference form
    And I have completed the background check form
    And I have navigated away from the wizard
    When I come back to the wizard
    Then the personal information form should populated with the details I've entered so far
    And  the contact information form should populated with the details I've entered so far
    And  the subject preference form should populated with the details I've entered so far
    And  the placement preference form should populated with the details I've entered so far
    And  the background check form should populated with the details I've entered so far

