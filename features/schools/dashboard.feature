Feature: The School Dashboard
    To help me gain an insight into tasks that need to be addressed
    As a school administrator
    I want to be able see a high-level view of tasks

    Background:
        Given I am logged in as a DfE user

    Scenario: Site header
        Given I am on the 'schools dashboard' page
        Then the main site header should be 'Manage school experience'

    Scenario: Root redirect
        Given I navigate to the 'schools' path
        Then I should see the dashboard

    @wip
    Scenario: High priority headings
        Given I am on the 'schools dashboard' page
        Then I should see the following 'high-priority' links:
            | Text                       | Hint                                        | Path                                 |
            | Accept and reject requests | Candidates have requested school experience | /schools/placement_requests/upcoming |
            | Accept and reject bookings | A candidate has asked to change a booking   | #                                    |

    @wip
    Scenario: Medium priority headings
        Given I am on the 'schools dashboard' page
        Then I should see the following 'medium-priority' links:
            | Text                         | Hint                                                                  | Path |
            | Confirm candidate attendance | Confirm the attendance of candidates who've been on school experience | #    |
            | View upcoming bookings       | None                                                                  | #    |

    @wip
    Scenario: Low priority headings
        Given I am on the 'schools dashboard' page
        Then I should see the following 'low-priority' links:
            | Text                                    | Hint | Path |
            | Read about service updates and changes  | None | #    |
            | Edit school profile                     | None | #    |
            | View old bookings Read service guidance | None | #    |
            | View rejected requests                  | None | #    |
            | Give feedback on this service           | None | #    |

    @wip
    Scenario: Candidate requests counter
        Given there are 5 new requests
        When I am on the 'schools dashboard' page
        Then the 'new requests counter' should be 5

    @wip
    Scenario: Candidate bookings counter
        Given there are 3 new bookings
        When I am on the 'schools dashboard' page
        Then the 'new bookings counter' should be 3

    @wip
    Scenario: Candidate attendances counter
        Given there are 4 new candidate attendances
        When I am on the 'schools dashboard' page
        Then the 'candidate attendances counter' should be 4
