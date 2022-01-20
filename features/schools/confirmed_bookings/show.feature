Feature: Viewing a booking
    To help me make decisions about school experience requests
    As a school administrator
    I want to be able to view all submitted information

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded
        And the school has subjects
        And the scheduled booking date is in the future

    Scenario: Page title
        Given there is at least one booking
        When I am viewing my chosen booking
        Then the page title should start with 'Booking details'
        And the page title should include the booking reference

    Scenario: Breadcrumbs
        Given there is at least one booking
        When I am viewing my chosen booking
        Then I should see the following breadcrumbs:
            | Text           | Link               |
            | Some school    | /schools/dashboard |
            | Bookings       | /schools/bookings  |
            | Booking        | None               |

    @smoke_test
    Scenario: Personal details
        Given there is at least one booking
        When I am viewing my chosen booking
        Then I should see a 'Personal details' section with the following values:
            | Heading             | Value                                                                 |
            | Address             | First Line, Second Line, Third Line, Manchester, Manchester, TE57 1NG |
            | UK telephone number | 01234 567890                                                          |
            | Email address       | first@thisaddress.com                                                 |

    @smoke_test
    Scenario: Booking details
        Given there is at least one booking
        When I am viewing my chosen booking
        Then I should see a 'Booking details' section with the following values:
            | Heading          | Value                                                                  |
            | Subject          | Biology                                                                |
            | DBS certificate  | Yes - Candidate says they have DBS certificate \(not verified by DfE\) |
            | Request received | \d{1,2}\s\w+\s\d{4}                                                      |
        And the future booking date should be listed

    @smoke_test
    Scenario: Candidate details
        Given there is at least one booking
        When I am viewing my chosen booking
        Then I should see a 'Candidate details' section with the following values:
            | Heading                                 | Value                             |
            | What they want out of school experience | It’s just an idea                 |
            | Degree stage                            | Final year                        |
            | Degree subject                          | Bioscience                        |
            | Teaching stage                          | I want to be a teacher            |
            | Teaching subject                        | First choice: Biology             |
            | Teaching subject                        | Second choice: Maths              |

    Scenario: Without a candidate cancellation
        Given there is at least one booking
        When I am viewing my chosen booking
        Then I should not see a 'Cancellation details' section

    @smoke_test
    Scenario: Candidate cancellation details
        Given there is a booking cancelled by the candidate
        When I am viewing my chosen booking
        Then I should see a 'Cancellation details' section with the following values:
            | Heading              | Value              |
            | Cancellation reason  | MyText             |
            | Cancellation sent at | \d{1,2}\s\w+\s\d{4}|

    @smoke_test
    Scenario: School Cancellation details
        Given there is a booking cancelled by the school
        When I am viewing my chosen booking
        Then I should see a 'Cancellation details' section with the following values:
            | Heading              | Value              |
            | Cancellation reason  | MyText             |
            | Cancellation sent at | \d{1,2}\s\w+\s\d{4}|
