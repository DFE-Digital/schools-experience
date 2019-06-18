Feature: Account operations
    To indicate the details of the DfE Signin account I am using
    As a school administrator
    I want to be able an indicator of who I am

    Background:
        Given I am logged in as a DfE user

    Scenario: My name and log out link
        Given I am on the 'schools dashboard' page
        Then I should see my name in the phase banner
        And there should be a 'Logout' link in the phase banner
