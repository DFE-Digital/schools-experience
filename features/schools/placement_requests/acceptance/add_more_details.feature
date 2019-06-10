Feature: Accepting placement requests
    So I can assist candidates who have applied at my school
    As a school administrator
    I want to be able to provide them with more information

    Background:
        Given I am logged in as a DfE user
        And the subjects 'Biology' and 'Chemistry' exist
        And there is a new placement request
        And I have completed the 'confirm booking' page

    Scenario: Page heading
        Given I have progressed to the 'add more details' page for my chosen placement request
        Then the page's main header should be 'Add more booking details'
        And the subheading should be 'Enter contact and location details'

    Scenario: Page contents
        Given I have progressed to the 'add more details' page for my chosen placement request
        Then I should see a form with the following fields:
            | Label          | Type     |
            | Contact name   | text     |
            | Contact number | tel      |
            | Contact email  | email    |
            | Location       | textarea |

    Scenario: Filling in and submitting the form
        Given I have progressed to the 'add more details' page for my chosen placement request
        And I have entered the following details into the form:
            | Contact name   | Dewey Largo                                       |
            | Contact number | 01234 567 890                                     |
            | Contact email  | dlargo@springfield.edu                            |
            | Location       | Please come to the reception in the East Building |
        When I submit the form
        Then I should be on the 'review and send email' page for my chosen placement request
        And the relevant fields in the booking should have been saved

    Scenario: Back link
        Given I have progressed to the 'add more details' page for my chosen placement request
        Then there should be a link back to the placement request
