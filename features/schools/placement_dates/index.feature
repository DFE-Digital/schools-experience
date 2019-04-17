Feature: Listing placement dates
    So I can manage my placement dates
    As a school administrator
    I want an overview of existing dates

    Background:
        Given I am logged in as a DfE user
        And my school has a profile

    Scenario: Page title
        Given I am on the 'placement dates' page
        Then the page title should be 'Placement dates'

    Scenario: Back link
        Given I am on the 'placement dates' page
        Then I should see a 'Back' link to the 'schools dashboard'

    Scenario: List contents
        Given my school has 5 placement dates
        When I am on the 'placement dates' page
        Then I should see a list with 5 entries

    Scenario: List contents
        Given my school has a placement date
        When I am on the 'placement dates' page
        Then I should my placement date listed
        And it should include a 'Change' link to the edit page

    Scenario: The add a new placement date button
        Given I am on the 'placement dates' page
        Then there should be a 'Add new placement date' link to the new placement date page
