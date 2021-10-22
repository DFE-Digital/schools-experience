Feature: Placing a placement request under consideration
  To help me better manage my placement requests
  As a school administrator
  I want to be able to place a placement request under consideration

  Background:
    Given I am logged in as a DfE user
    And my school is fully-onboarded
    And the school has subjects

  Scenario: Place under consideration button
    Given there is at least one placement request
    When I am on the placement request page
    Then there should be the following buttons:
      | Place under consideration |

  Scenario: Placing a request under consideration
    Given there is at least one placement request
    And I am on the placement request page
    When I click the 'Place under consideration' button
    Then the under consideration request should have a status of 'Under consideration'