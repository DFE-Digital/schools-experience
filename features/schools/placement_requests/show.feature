Feature: Viewing a placement request
    To help me make decisions about school experience requests
    As a school administrator
    I want to be able to view all submitted information

    Background:
        Given I am logged in as a DfE user
        And the subjects 'Biology' and 'Chemistry' exist

    Scenario: Back link
        Given there is at least one placement request
        When I am on the placement request page
        Then I should see a 'Back' link to the 'upcoming requests' page

    Scenario: Personal details
        Given there is at least one placement request
        When I am on the placement request page
        Then I should see a 'Personal details' section with the following values:
            | Heading             | Value                                                                |
            | Address             | First Line, Second Line, Third Line, Manchester, Manchester, MA1 1AM |
            | UK telephone number | 07123 456789                                                         |
            | Email address       | second@thisaddress.com                                               |

    Scenario: Request details
        Given there is at least one placement request
        When I am on the placement request page
        Then I should see a 'Request details' section with the following values:
            | Heading         | Value                 |
            | Dates requested | Every second Thursday |
            | DBS certificate | Yes                   |

    Scenario: Candidate details
        Given there is at least one placement request
        When I am on the placement request page
        Then I should see a 'Candidate details' section with the following values:
            | Heading                                 | Value                  |
            | What they want out of school experience | I want to be a teacher |
            | Degree stage                            | Final year             |
            | Degree subject                          | Bioscience             |
            | Teaching stage                          | I want to be a teacher |
            | Preferred subjects                      | Biology                |

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
