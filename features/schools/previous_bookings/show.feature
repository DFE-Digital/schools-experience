Feature: Viewing a previous booking
    To help me review past school experience bookings
    As a school administrator
    I want to be able to view all submitted information

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded
        And the scheduled booking date is in the past

    Scenario: Page title
        Given there is at least one previous booking
        When I am viewing my chosen previous booking
        Then the page title should start with 'Booking details'
        And the page title should include the booking reference

    Scenario: Breadcrumbs
        Given there is at least one previous booking
        When I am viewing my chosen previous booking
        Then I should see the following breadcrumbs:
            | Text              | Link                        |
            | Some school       | /schools/dashboard          |
            | Previous bookings | /schools/previous_bookings  |
            | Booking           | None                        |

    Scenario: Personal details
        Given there is at least one previous booking
        When I am viewing my chosen previous booking
        Then I should see a 'Personal details' section with the following values:
            | Heading             | Value                                                                 |
            | Address             | First Line, Second Line, Third Line, Manchester, Manchester, TE57 1NG |
            | UK telephone number | 07123 456789                                                          |
            | Email address       | second@thisaddress.com                                                |

    Scenario: Booking details
        Given there is at least one previous booking
        When I am viewing my chosen previous booking
        Then I should see a 'Booking details' section with the following values:
            | Heading          | Value                                                                  |
            | Subject          | Biology                                                                |
            | DBS certificate  | Yes - Candidate says they have DBS certificate \(not verified by DfE\) |
            | Request received | 08 February 2019                                                       |
        And the future booking date should be listed

    Scenario: Candidate details
        Given there is at least one previous booking
        When I am viewing my chosen previous booking
        Then I should see a 'Candidate details' section with the following values:
            | Heading                                 | Value                             |
            | What they want out of school experience | It’s just an idea                 |
            | Degree stage                            | Final year                        |
            | Degree subject                          | Bioscience                        |
            | Teaching stage                          | I want to be a teacher            |
            | Teaching subject                        | First choice: Biology             |
            | Teaching subject                        | Second choice: Biology            |

    Scenario: Without a candidate cancellation
        Given there is at least one previous booking
        When I am viewing my chosen previous booking
        Then I should not see a 'Cancellation details' section

    Scenario: Cancellation details
        Given there is a cancelled previous booking
        When I am viewing my chosen previous booking
        Then I should see a 'Cancellation details' section with the following values:
            | Heading              | Value             |
            | Cancellation reason  | MyText            |
            | Cancellation sent at | \d{2}\s\w+\s\d{4} |
