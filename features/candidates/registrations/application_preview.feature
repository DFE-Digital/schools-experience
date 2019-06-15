Feature: Previewing my application
    So I can confirm the accuracy of my submission
    As a potential candidate
    I want to check my data before I submit it

    Background:
        Given my school of choice exists
        And my school of choice offers 'Physics'

    Scenario: Page contents (when the school has flexible availability)
        Given my school has flexible dates
        And I have completed the wizard
        When I am on the 'Check your answers' page for my choice of school
        Then I should see the following summary rows:
            | Heading                 | Value                  | Change link path                                                   |
            | Experience availability | Epiphany to Whitsunday | /candidates/schools/123456/registrations/placement_preference/edit |

    Scenario: Page contents (when the school has fixed availability)
        Given my school has fixed dates
        And I have completed the wizard
        When I am on the 'Check your answers' page for my choice of school
        Then I should see a summary row containing my selected date
        And the row should have a 'Change' link to '/candidates/schools/123456/registrations/placement_preference/edit'
