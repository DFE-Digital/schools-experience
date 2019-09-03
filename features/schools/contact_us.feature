Feature: The School Dashboard
    To provide me with assistance if I need it
    As a school administrator
    I want to be able to contact the suitable person at the DfE

    Background:
        Given I am logged in as a DfE user

    Scenario: Links
        Given I am on the 'contact us' page
        Then I should see a email link to 'organise.school-experience@education.gov.uk'
        And I should see a 'Return to requests and bookings' link to the 'schools dashboard'
