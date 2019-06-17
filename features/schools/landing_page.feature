Feature:
    So I can learn about managing school experience for my school
    As a school administrator
    I want to be able to read some useful information on the topic

    Scenario: Page heading and title
        Given I am on the 'schools' page
        Then the page's main heading should be 'Manage school experience'
        And the page title should be 'Manage school experience'

    Scenario: Start now button
        Given I am on the 'schools' page
        Then there should be a 'Start now' link to the 'schools dashboard'
