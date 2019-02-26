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
            | Do you have any disability or access needs? | radio buttons | Yes, No |

    Scenario: Word counting in placement objectives
        Given I am on the 'Request school experience placement' page for my school of choice
        Then the 'placement objectives' word count should say 'You have 50 words remaining'

    Scenario: Updating the word count
        Given I am on the 'Request school experience placement' page for my school of choice
        When I enter 'The quick brown fox' into the 'What do you want to get out of a placement?' text area
        Then the 'placement objectives' word count should say 'You have 46 words remaining'

    Scenario: Disability details
        Given I am on the 'Request school experience placement' page for my school of choice
        Then the 'Disability needs' section should have 'Yes' and 'No' radio buttons

    @javascript @wip
    Scenario: Revealing the 'Provide details' box
        Given I am on the 'Request school experience placement' page for my school of choice
        And there is no 'Provide details' text area
        When I click the 'Yes' option in the 'Disability needs' section
        Then a text area labelled 'Provide details' should have appeared

    Scenario: Submitting my data
        Given I am on the 'Request school experience placement' page for my school of choice
        And I have filled in the form with accurate data
        When I submit the form
        Then I should be on the 'Enter your contact details' page for my school of choice
