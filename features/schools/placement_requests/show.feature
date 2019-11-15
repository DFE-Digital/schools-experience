Feature: Viewing a placement request
    To help me make decisions about school experience requests
    As a school administrator
    I want to be able to view all submitted information

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded
        And the school has subjects

    Scenario: Back link
        Given there is at least one placement request
        When I am on the placement request page
        Then I should see a 'Back' link to the 'placement requests' page

    Scenario: Personal details
        Given there is at least one placement request
        When I am on the placement request page
        Then I should see a 'Personal details' section with the following values:
            | Heading             | Value                                                                 |
            | Address             | First Line, Second Line, Third Line, Manchester, Manchester, TE57 1NG |
            | UK telephone number | 07123 456789                                                          |
            | Email address       | second@thisaddress.com                                                |

    Scenario: Request details
        Given there is at least one placement request
        When I am on the placement request page
        Then I should see a 'Request details' section with the following values:
            | Heading         | Value                         |
            | Dates requested | Any time during November 2019 |
            | DBS certificate | Yes                           |

    Scenario: Request details
        Given there is at least one subject-specific placement request for 'Maths'
        When I am on the placement request page
        Then I should see a 'Request details' section with the following values:
            | Requested subject | Maths                         |

    Scenario: Candidate details
        Given there is at least one placement request
        When I am on the placement request page
        Then I should see a 'Candidate details' section with the following values:
            | Heading                                 | Value                                                                    |
            | What they want out of school experience | To learn different teaching styles and what life is like in a classroom. |
            | Degree stage                            | Final year                                                               |
            | Degree subject                          | Law                                                                      |
            | Teaching stage                          | I’ve applied for teacher training                                        |
            | Preferred subjects                      | Maths, Physics                                                           |

    Scenario: Buttons
        Given there is at least one placement request
        When I am on the placement request page
        Then there should be the following buttons:
            | Accept request |
            | Reject request |

    Scenario: Accepting a request
        Given there is at least one placement request
        And I am on the placement request page
        When I click the 'Accept request' button
        Then I should be on the confirm booking page
