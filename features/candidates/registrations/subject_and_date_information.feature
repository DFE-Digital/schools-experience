Feature: Selecting a subject and date
    So I can tell the school which date and subject combination I want
    As a potential candidate
    I want to choose the best option from a list

    Background:
        Given my school of choice exists
        And it has 'fixed' availability

    Scenario: When the school is a primary school
        Given the school is a 'primary' school
        And the school has some primary placement dates set up
        When I am on the 'choose a subject and date' screen for my chosen school
        Then I should see the list of primary placement dates

    Scenario: When the school is a secondary school
        Given the school is a 'secondary' school
        And the school has some secondary placement dates set up
        When I am on the 'choose a subject and date' screen for my chosen school
        Then I should see the list of secondary placement dates

    Scenario: When the school is a primary and secondary school
        Given the school is a 'primary and secondary' school
        And the school has both primary and secondary dates set up
        When I am on the 'choose a subject and date' screen for my chosen school
        Then I should see the list of primary placement dates
        And I should see the list of secondary placement dates
