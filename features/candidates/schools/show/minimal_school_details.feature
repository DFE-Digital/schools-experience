Feature: School show page (minimal data)
    To help me evaluate a school
    As a potential candidate
    I want to be able to view a scohol's details

    Background:
        Given there is a school called 'Springfield Elementary'

    Scenario: Subjects listing when school has no subjects
        Given my chosen school has no subjects
        When I am on the profile page for the chosen school
        Then the subjects section should not be displayed

    Scenario: Subjects listing when school has no placement information
        Given my chosen school has no placement information
        When I am on the profile page for the chosen school
        Then the placement information section should not be visible
