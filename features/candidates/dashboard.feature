Feature: View Dashboard page
    Login as a Candidate
    I want to see my Dashboard showing my Placement Requests and Bookings
    
    Scenario: Viewing the Dashboard when signed out
        Given I visit the Dashboard page
        Then I should be redirected to the candidate signin page
    
    Scenario: Signing in and Viewing the Dashboard
        Given I am on the candidate signin page
        When I should enter my name and email address
        And I click the 'Sign in' button
        And I follow the sign in link from the email
        Then I will see the Dashboard page
    
    Scenario: Signing in with expired signin link
        Given I use an expired signin link
        Then I will see the link expired page
