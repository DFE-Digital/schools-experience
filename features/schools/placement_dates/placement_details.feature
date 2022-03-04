Feature: Creating new placement details
  So I can add placement details
  As a school administrator
  I want to be able to specify and create details

  Background:
    Given I am logged in as a DfE user
    And my school is fully-onboarded

  Scenario: Placement details form
    Given I have entered a placement date
    Then I should see a form with the following fields:
      | Label                                              | Type   |
      | How long will it last?                             | number |
      | When do you want to close this date to candidates? | number |
      | When do you want to publish this date?             | number |

  Scenario: Primary and secondary schools: extra option
    Given my school is a 'primary and secondary' school
    And I have entered a placement date
    Then I should see radio buttons for 'Select school experience phase' with the following options:
      | Primary including early years, key stage 1 and key stage 2                      |
      | Secondary including secondary schools, sixth-forms, colleges and 16 to 18 years |

  Scenario: Primary and secondary schools: selecting primary
    Given my school is a 'primary and secondary' school
    And I have entered a placement date
    When I fill in the placement details form with a duration of 3
    And I choose 'Primary including early years, key stage 1 and key stage 2' from the 'Select school experience phase' radio buttons
    And I submit the form
    Then I should be on the 'placement dates' page
    And my school should be enabled

  Scenario: Primary and secondary schools: selecting secondary
    Given my school is a 'primary and secondary' school
    And I have entered a placement date
    When I fill in the placement details form with a duration of 3
    And I choose 'Secondary including secondary schools, sixth-forms, colleges and 16 to 18 years' from the 'Select school experience phase' radio buttons
    And I submit the form
    Then I should be on the new configuration page for my placement date
    And there should be a subject specificity option
