Feature: Confirming candidate attendance
    So we have a record of which candidates attended our school
    As a school administrator
    I want to be able to mark bookings as attended or not

    Background:
        Given I am logged in as a DfE user
        And the school offers 'Biology, Chemistry'
        And my school is fully-onboarded

    Scenario: When there are no bookings
        Given there are no bookings
        When I am on the 'confirm attendance' page
        Then I should see a notification that 'There are no bookings that need their attendance to be confirmed'
        And I should see a secondary 'Return to requests and bookings' link to the 'schools dashboard'

    Scenario: Listing bookings
        Given there are some bookings that were scheduled last week
        When I am on the 'confirm attendance' page
        Then I should see a table containing those bookings

    Scenario: Not listing cancelled bookings
        Given there are some cancelled bookings that were scheduled last week
        When I am on the 'confirm attendance' page
        Then no bookings should be listed

    Scenario: Table contents
        Given there are some bookings that were scheduled last week
        When I am on the 'confirm attendance' page
        Then I should see a table with the following headings:
            | Name     |
            | Subject  |
            | Date     |
            | Attended |
        And the correct data should be present in each row

    Scenario: Setting a booking as attended
        Given there are some bookings that were scheduled last week
        And I am on the 'confirm attendance' page
        When I select 'Yes' for the first booking
        And I click the 'Save and return to requests and bookings' submit button
        Then I should be on the 'schools dashboard' page
        And the booking should be marked as attended

    Scenario: Setting a booking as not attended
        Given there are some bookings that were scheduled last week
        And I am on the 'confirm attendance' page
        When I select 'No' for the first booking
        And I click the 'Save and return to requests and bookings' submit button
        Then I should be on the 'schools dashboard' page
        And the booking should be marked as not attended

    Scenario: Only selected records are updated
        Given I have set a booking to be attended
        Then the other bookings should not be updated
