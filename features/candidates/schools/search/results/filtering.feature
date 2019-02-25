Feature: Filtering school search results
    To help me hone a search
    As a potential candidate
    I want to be able to narrow down search results

    Scenario: Filtering by Education Phase
        Given I have searched for 'Manchester' and am on the results page
        Then I should see a 'Phases' filter on the left
        And it should have the hint text 'Select all that apply'
        And it should have checkboxes for the following items:
            | Primary   |
            | Secondary |

    Scenario: Filtering by Fees
        Given there are some subjects
        When I have searched for 'Manchester' and am on the results page
        Then I should see a 'Max fee' filter on the left
        And it should have the hint text 'Schools may charge'
        And it should have radio buttons for the following items:
            | None      |
            | up to £30 |
            | up to £60 |
            | up to £90 |

    Scenario: Filtering by Subject
        Given there are some subjects
        When I have searched for 'Manchester' and am on the results page
        Then I should see a 'Subject' filter on the left
        And it should have the hint text 'Select all that apply'
        And it should have checkboxes for all subjects
