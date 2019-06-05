Feature: Viewing a booking
    To help me make decisions about school experience requests
    As a school administrator
    I want to be able to view all submitted information

    Background:
        Given I am logged in as a DfE user

    Scenario: Breadcrumbs
        Given I am on a 'booking' page
        Then I should see the following breadcrumbs:
            | Text           | Link              |
            | Some school    | /schools          |
            | All bookings   | /schools/bookings |
            | Booking abc123 | None              |

    Scenario: Personal details
        Given there is at least one booking
        When I am on a 'booking' page
        Then I should see a 'Personal details' section with the following values:
            | Heading             | Value                                                                |
            | Address             | First Line, Second Line, Third Line, Manchester, Manchester, MA1 1AM |
            | UK telephone number | 07123 456789                                                         |
            | Email address       | second@thisaddress.com                                               |

    Scenario: Request details
        Given there is at least one booking
        When I am on a 'booking' page
        Then I should see a 'Booking details' section with the following values:
            | Heading          | Value            |
            | Date             | 02 October 2019  |
            | Request received | 08 February 2019 |
            | DBS certificate  | Yes              |
            | Status           | New              |

    Scenario: Candidate details
        Given there is at least one booking
        When I am on a 'booking' page
        Then I should see a 'Candidate details' section with the following values:
            | Heading                                 | Value                                                                    |
            | What they want out of school experience | To learn different teaching styles and what life is like in a classroom. |
            | Degree stage                            | Final year                                                               |
            | Degree subject                          | Maths                                                                    |
            | Teaching stage                          | I've applied for teacher training                                        |
            | Preferred subjects                      | Maths, Physics                                                           |
