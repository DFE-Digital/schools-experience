Feature: Viewing a rejected request
    To help me review a rejected placement request
    As a school administrator
    I want to be able to view all submitted information

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded
        And it has 'fixed' availability
        And the school has subjects

    Scenario: Page title
        Given there is at least one rejected request
        When I am viewing the rejected request
        Then the page title should start with 'Rejected request'

    Scenario: Breadcrumbs
        Given there is at least one rejected request
        When I am viewing the rejected request
        Then I should see the following breadcrumbs:
            | Text               | Link                         |
            | Some school        | /schools/dashboard           |
            | Rejected requests  | /schools/rejected_requests  |
            | Request            | None                         |

    @smoke_test
    Scenario: Rejection details
        Given there is at least one rejected request
        When I am viewing the rejected request
        Then I should see a 'Rejection details' section with the following values:
            | Heading      | Value      |
            | Reason       | MyText     |

    @smoke_test
    Scenario: Rejection category
        Given a request has been rejected because of 'date_not_available'
        When I am viewing the rejected request
        Then I should see a rejected request with the rejection reason displayed in full

    @smoke_test
    Scenario: Personal details
        Given there is at least one rejected request
        When I am viewing the rejected request
        Then I should see a 'Personal details' section with the following values:
            | Heading             | Value                                                                 |
            | Address             | First Line, Second Line, Third Line, Manchester, Manchester, TE57 1NG |
            | UK telephone number | 01234 567890                                                          |
            | Email address       | first@thisaddress.com                                                 |

    @smoke_test
    Scenario: Request details
        Given there is at least one rejected request
        When I am viewing the rejected request
        Then I should see a 'Request details' section with the following values:
            | Heading          | Value            |
            | Dates requested  | \d+ [a-z]+ \d{4} |
            | DBS certificate  | Yes              |
            | Request received | \d+ [a-z]+ \d{4} |

    @smoke_test
    Scenario: Candidate details
        Given there is at least one rejected request
        When I am viewing the rejected request
        Then I should see a 'Candidate details' section with the following values:
            | Heading                                 | Value                                             |
            | What they want out of school experience | Become a teacher                                  |
            | Degree stage                            | I don't have a degree and am not studying for one |
            | Degree subject                          | Not applicable                                    |
            | Teaching stage                          | I’m very sure and think I’ll apply                |
            | Teaching subject                        | First choice: Maths                               |
            | Teaching subject                        | Second choice: Physics                            |
