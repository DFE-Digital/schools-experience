Feature: Accepting placement requests
    So I can allow candidates to visit my school for placements
    As a school administrator
    I want to be able to accept placement requests and create bookings

    Background:
        Given I am logged in as a DfE user
        And the subjects 'Biology' and 'Chemistry' exist
        And there is a new placement request

    Scenario: Page title
        Given I am on the 'confirm booking' page for my chosen placement request
        Then the page title should be 'Confirm booking'

    Scenario: Page heading
        Given I am on the 'confirm booking' page for my chosen placement request
        Then the page's main header should be 'Confirm booking'
        And the subheading should be 'Confirm the booking for' followed by the candidate's name

    Scenario: Placement request details
        Given I am on the 'confirm booking' page for my chosen placement request
        Then there should be a list containing school and placement request data

    Scenario: Form contents
        Given I am on the 'confirm booking' page for my chosen placement request
        Then I should see a form with the following fields:
            | Label                      | Type     | Options            |
            | Confirm experience date    | date     |                    |
            | Confirm subject            | select   | Biology, Chemistry |
            | Confirm experience details | textarea |                    |

    Scenario: Defaulting the subject
        Given my placement request first choice was 'Biology'
        When I am on the 'confirm booking' page for my chosen placement request
        Then the subject should be set to 'Biology' by default

    Scenario: Defaulting the date when the school has fixed dates
        Given my school is set to use 'fixed' dates
        When I am on the 'confirm booking' page for my fixed placement request
        Then the date should be pre-populated
        And the original date should be listed on the page

    Scenario: Entering an invalid date
        Given my school is set to use 'fixed' dates
        When I am on the 'confirm booking' page for my fixed placement request
        And I select 'Chemistry' from the 'Confirm subject' select box
        And I enter "It's a really exciting day" into the "Confirm experience details" text area
        And I fill in the 'Confirm experience date' date field with an invalid date of 31st September next year
        And I submit the form
        Then I should see an error message stating 'not a valid date'

    Scenario: The date should be blank when the school has flexible dates
        Given my school is set to use 'flexible' dates
        When I am on the 'confirm booking' page for my flexible placement request
        Then the date fields should be empty

    Scenario: Defaulting the placement details
        Given my school has some placement details
        When I am on the 'confirm booking' page for my chosen placement request
        Then the placement details should match the school's placement details

    Scenario: Submitting the form
        Given I am on the 'confirm booking' page for my chosen placement request
        And I enter three weeks from now as the date
        And I select 'Chemistry' from the 'Confirm subject' select box
        And I enter "It's a really exciting day" into the "Confirm experience details" text area
        When I submit the form
        Then I should be on the 'add more details' page for my chosen placement request

    Scenario: Back link
        Given I am on the 'confirm booking' page for my chosen placement request
        Then there should be a link back to the placement request
