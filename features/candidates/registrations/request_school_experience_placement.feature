Feature: Request a school experience placement
    So I can register my interest in a placement with a school
    As a potential candidate
    I want to submit my details to the school

    Scenario: Page title and description
        Given I am on the 'Request school experience placement' page for my school of choice
        Then the page's main header should be 'Request school experience placement'

    Scenario: Form contents
        Given I am on the 'Request school experience placement' page for my school of choice
        Then I should see a form with the following fields:
            | Label                                       | Type          | Options |
            | Start date                                  | date          |         |
            | End date                                    | date          |         |
            | What do you want to get out of a placement? | textarea      |         |

    @javascript
    Scenario: Word counting in placement objectives
        Given I am on the 'Request school experience placement' page for my school of choice
        Then the 'What do you want to get out of a placement?' word count should say 'You have 150 words remaining'

    @javascript
    Scenario: Updating the word count
        Given I am on the 'Request school experience placement' page for my school of choice
        When I enter 'The quick brown fox' into the 'What do you want to get out of a placement?' text area
        Then the 'What do you want to get out of a placement?' word count should say 'You have 146 words remaining'

    Scenario: Submitting my data
        Given I am on the 'Request school experience placement' page for my school of choice
        And I have filled in the form with accurate data
        When I submit the form
        Then I should be on the 'Enter your contact details' page for my school of choice
