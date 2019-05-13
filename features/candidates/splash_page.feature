Feature: Candidate splash page
    To explain how the service works
    As a potential candidate
    I want to read an overview of the what the service offers

    Scenario: Page heading
        Given I am on the 'splash' page
        Then the page's main header should be 'How the service works'

    Scenario: Site header
        Given I am on the 'splash' page
        Then the main site header should be 'Get school experience'

    Scenario: The continue button
        Given I am on the 'splash' page
        When I click the 'Continue' button
        Then I should be on the 'find a school' page
