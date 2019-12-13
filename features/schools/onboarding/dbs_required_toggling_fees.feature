Feature: Dbs required toggling available fees

  Background: I have completed the wizard thus far
    Given I am logged in as a DfE user
    And the secondary school phase is availble
    And the college phase is availble
    And there are some subjects available
    And A school is returned from DFE sign in

  Scenario: New DBS requirement chosing Yes
    Given I have completed the DBS Requirements step
    When I am on the 'fees charged' page
    Then I should see radio buttons for 'DBS check costs' with the following options:
      | Yes |
      | No  |

  Scenario: New DBS requirement chosing No
    Given I have completed the DBS Requirements step, choosing No
    When I am on the 'fees charged' page
    Then I should not see 'DBS check costs'

  Scenario: Edit DBS requirement from Yes to No
    Given I have completed the following steps:
        | Step name                        | Extra                     |
        | DBS Requirements                 |                           |
        | Candidate Requirements choice    |                           |
        | Candidate Requirements selection |                           |
        | Fees                             | choosing only Other costs |
        | Other costs                      |                           |
        | Phases                           |                           |
        | Subjects                         |                           |
        | Description                      |                           |
        | Access needs support             |                           |
        | Access needs detail              |                           |
        | Disability confident             |                           |
        | Access needs policy              |                           |
        | Candidate experience details     |                           |
        | Experience Outline               |                           |
        | Admin contact                    |                           |
    And I am on the 'edit DBS requirements' page
    And I choose 'No - Candidates will be accompanied at all times' from the 'Do you require candidates to have or get a DBS check?' radio buttons
    When I submit the form
    Then I should be on the 'profile' page

  Scenario: Edit DBS requirement from Yes to No
    Given I have completed the following steps:
        | Step name                        | Extra                     |
        | DBS Requirements                 | choosing No               |
        | Candidate Requirements choice    |                           |
        | Candidate Requirements selection |                           |
        | Fees                             | choosing only Other costs |
        | Other costs                      |                           |
        | Phases                           |                           |
        | Subjects                         |                           |
        | Description                      |                           |
        | Access needs support             |                           |
        | Access needs detail              |                           |
        | Disability confident             |                           |
        | Access needs policy              |                           |
        | Candidate experience details     |                           |
        | Experience Outline               |                           |
        | Admin contact                    |                           |
    And I am on the 'edit DBS requirements' page
    And I choose 'Yes - Outline your DBS requirements' from the 'Do you require candidates to have or get a DBS check?' radio buttons
    And I enter 'Always require DBS check' into the 'Provide details in 50 words or less.' text area
    And I submit the form
    And I choose 'Yes' from the 'DBS check costs' radio buttons
    When I submit the form
    Then I should be on the 'DBS check costs' page
