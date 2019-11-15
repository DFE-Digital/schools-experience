Feature: Fees
  So I can ensure we don't surprise candidates
  As a school administrator
  I want to specify the fees we charge candidates for their placement

  Background: I have completed the candidate requirement step
    Given I am logged in as a DfE user
    And the secondary school phase is availble
    And the college phase is availble
    And I have completed the DBS Requirements step
    And I have completed the Candidate Requirements choice step
    And I have completed the Candidate Requirements selection step

  Scenario: Page title
    Given I am on the 'fees charged' page
    Then the page title should be 'Do you charge fees to cover any of the following?'

  Scenario: Breadcrumbs
    Given I am already on the 'fees charged' page
    Then I should see the following breadcrumbs:
        | Text                                              | Link               |
        | Some school                                       | /schools/dashboard |
        | Do you charge fees to cover any of the following? | None               |

  Scenario: Completing step choosing Adminsitration costs only
    Given I am on the 'fees charged' page
    And I choose 'Yes' from the 'Administration costs' radio buttons
    And I choose 'No' from the 'DBS check costs' radio buttons
    And I choose 'No' from the 'Other costs' radio buttons
    When I submit the form
    Then I should be on the 'Administration costs' page

  Scenario: Completing step choosing DBS costs only
    Given I am on the 'fees charged' page
    And I choose 'Yes' from the 'DBS check costs' radio buttons
    And I choose 'No' from the 'Administration costs' radio buttons
    And I choose 'No' from the 'Other costs' radio buttons
    When I submit the form
    Then I should be on the 'DBS check costs' page

  Scenario: Completing step choosing Other costs only
    Given I am on the 'fees charged' page
    And I choose 'Yes' from the 'Other costs' radio buttons
    And I choose 'No' from the 'DBS check costs' radio buttons
    And I choose 'No' from the 'Administration costs' radio buttons
    When I submit the form
    Then I should be on the 'Other costs' page

  Scenario: Completing step choosing all costs
    Given I am on the 'fees charged' page
    And I choose 'Yes' from the 'Administration costs' radio buttons
    And I choose 'Yes' from the 'DBS check costs' radio buttons
    And I choose 'Yes' from the 'Other costs' radio buttons
    When I submit the form
    Then I should be on the 'Administration costs' page
