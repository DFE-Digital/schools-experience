Feature: Dbs required toggling available fees

  Background: I have completed the wizard thus far
    Given I am logged in as a DfE user
    And the secondary school phase is availble
    And the college phase is availble
    And there are some subjects available
    And A school is returned from DFE sign in

  Scenario: New DBS requirement choosing Yes
    Given I have completed the DBS Requirements step
    When I am on the 'fees charged' page
    Then there should be a "DBS check costs" checkbox

  Scenario: New DBS requirement choosing No
    Given I have completed the DBS Requirements step, choosing No
    When I am on the 'fees charged' page
    Then I should not see 'DBS check costs'

  Scenario: Edit DBS requirement from Yes to No
    Given I have completed the following steps:
        | Step name                        | Extra                     |
        | DBS Requirements                 |                           |
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
        | Candidate dress code             |                           |
        | Candidate parking information    |                           |
        | Candidate experience schedule    |                           |
        | Experience Outline               |                           |
        | Teacher training                 |                           |
        | Admin contact                    |                           |
    And I am on the 'edit DBS requirements' page
    And I choose 'No, candidates will be accompanied at all times' from the 'Do candidates need to have or get a DBS check?' radio buttons
    When I submit the form
    Then I should be on the 'profile' page

  Scenario: Edit DBS requirement from No to Yes
    Given I have completed the following steps:
        | Step name                        | Extra                     |
        | DBS Requirements                 | choosing No               |
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
        | Candidate dress code             |                           |
        | Candidate parking information    |                           |
        | Candidate experience schedule    |                           |
        | Experience Outline               |                           |
        | Teacher training                 |                           |
        | Admin contact                    |                           |
    And I am on the 'edit DBS requirements' page
    And I choose 'Yes, for in-school and virtual experience' from the 'Do candidates need to have or get a DBS check?' radio buttons
    And I enter 'Always require DBS check' into the 'Provide details in 50 words or less.' text area
    And I submit the form
    And I check 'DBS check costs'
    When I submit the form
    Then I should be on the 'DBS check costs' page
