Feature: Entering candidate contact details
    So I can be contacted by the school
    As a potential candidate
    I want to enter my address and telephone number

    Scenario: Page contents
        Given I am on the 'candidate address' page
        Then the page's main header should be "Unfortunately we don’t have your details"
        And there should be some information explaining why my contact details are needed
        And I should see a form with the following fields:
            | Label               | Type | Options |
            | Building and street | text |         |
            | Street              | text |         |
            | Town or city        | text |         |
            | County              | text |         |
            | Postcode            | text |         |
            | UK telephone number | tel  |         |

    Scenario: Filling in and submitting the form
        Given I am on the 'candidate address' page
        And I have entered the following details into the form:
            | Building and street | 221B           |
            | Street              | Baker Street   |
            | Town or city        | London         |
            | County              | Greater London |
            | Postcode            | NW1 6XE        |
            | UK telephone number | 07765 432 100  |
        When I submit the form
        Then I should be on the 'candidate subjects' page
