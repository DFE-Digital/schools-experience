Feature: School show page (fixed dates)
    To help me plan my school experience
    As a potential candidate
    I want to be able to view a school's details

    Background:
        Given the school I'm applying to is not flexible on dates
        And the school has 3 placements available in the upcoming weeks

    Scenario: Placement date display
        Given I am on the profile page for the chosen school
        Then I should see the list of 'Upcoming dates' in the sidebar
