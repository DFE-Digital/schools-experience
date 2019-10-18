Feature: Selecting a subject and date
    So I can tell the school which date and subject combination I want
    As a potential candidate
    I want to choose the best option from a list

    Background:
        Given my school of choice exists
        And it has 'fixed' availability

    Scenario: Heading
        Given I am on the 'choose a subject and date' screen for my chosen school
        Then the page's main heading should be 'Request a school experience date at'

    Scenario: Back link
        Given I am on the 'choose a subject and date' screen for my chosen school
        Then I should see a back link

    Scenario: Displaying durations
        Given the school is a 'primary and secondary' school
        And the school has both primary and secondary dates set up
        When I am on the 'choose a subject and date' screen for my chosen school
        Then I should see the duration listed in each radio button label

    Scenario: Displaying errors
        Given the school is a 'primary' school
        And the school has some primary placement dates set up
        When I am on the 'choose a subject and date' screen for my chosen school
        And I make no selection
        And I submit the form
        Then I should see an error and the date and subject options should be marked as being incorrect

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

    Scenario: Submitting the form
        Given the school is a 'primary and secondary' school
        And the school has a secondary date with Maths set up
        When I am on the 'choose a subject and date' screen for my chosen school
        And I select the first secondary date
        And I submit the form
        Then I should be on the 'enter your personal details' page for my chosen school
