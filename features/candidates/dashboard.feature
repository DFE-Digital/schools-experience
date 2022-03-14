Feature: View Dashboard page
    Login as a Candidate
    I want to see my Dashboard showing my Placement Requests and Bookings
    
    Background:
        Given there is a fully-onboarded school
        And the school has subjects

    Scenario: Viewing the Dashboard when signed out
        Given I visit the Dashboard page
        Then I should be redirected to the candidate signin page

    Scenario: Page title
        Given I am logged in as a candidate user
        When I visit the Dashboard page
        Then the page title should be 'Candidate dashboard'

    Scenario: List candidate's placements only
        Given I am logged in as a candidate user
        And there are some placement requests
        And there are some placement requests of the current user
        When I visit the Dashboard page
        Then I should see all my placement requests listed

    Scenario: Table contents
        Given I am logged in as a candidate user
        And there are some placement requests of the current user
        When I visit the Dashboard page
        Then I should see a table with the following headings:
            | Placement date |
            | School         |
            | Subject        |
            | Status         |
            | Action         |

    Scenario: Empty list
        Given I am logged in as a candidate user
        When I visit the Dashboard page
        Then I should see the text 'You have no placement requests or bookings'
        And I should not see the requests table
