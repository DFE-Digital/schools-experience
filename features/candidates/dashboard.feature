Feature: View Dashboard page
    Login as a Candidate
    I want to see my Dashboard showing my Placement Requests and Bookings
    
    Scenario: Viewing the Dashboard when signed out
        Given I visit the Dashboard page
        Then I should be redirected to the candidate signin page
    
    @wip
    Scenario: Signing in and Viewing the Dashboard
        Given I am on the candidate signin page
        When I enter my name and email address
        And I click the 'Sign in' button
        Then I will see the Verification Code page

