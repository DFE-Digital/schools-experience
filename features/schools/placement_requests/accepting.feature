Feature: Accepting placement requests
    So I can allow candidates to visit my school for placements
    As a school administrator
    I want to be able to accept placement requests

    Background:
        Given I am logged in

    Scenario: Back link
        Given there are some upcoming requests
        When I am on the 'upcoming requests' page
        Then I should see a 'Back' link to the 'schools dashboard'

    Scenario: Booking details
        Given there is at least once placement request
        When I am on the 'accept placement request' page
        Then I should see the following booking details:
            | Heading                   | Value                               |
            | School                    | Newton Heath School                 |
            | School experience dates   | 01 to 05 June 2019                  |
            | School experience details | You'll be observing lessons and may |
            | Requested subject         | Maths                               |
            | Request received          | 02 February 2019                    |

    Scenario: Booking details
        Given there is at least once placement request
        When I am on the 'accept placement request' page
        Then every row of the booking details list should have a 'Change' link

    Scenario: School contact form
        Given there is at least once placement request
        When I am on the 'accept placement request' page
        Then I should see a form with the following fields:
            | Label            | Type  |
            | Contact name     | text  |
            | Telephone number | tel   |
            | Email address    | email |
            | Location         | text  |
            | Other details    | text  |
        And the submit button should contain text 'Continue'
