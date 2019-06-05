Feature: Contact Information
  So I can be contacted about my placement request
  As a potential candidate
  I want to be able to provide my contact details

    Scenario: Page contents
        Given I am on the 'Enter your contact details' page for my school of choice
        Then the page's main header should be 'Enter your contact details'
        And I should see a paragraph informing me that my details will be used by schools to contact me

    Scenario: Form contents
        Given I am on the 'Enter your contact details' page for my school of choice
        Then I should see a form with the following fields:
            | Label               | Type  |
            | First name          | text  |
            | Last name           | text  |
            | Date of birth       | date  |
            | UK telephone number | tel   |
            | Email address       | email |
            | Building and street | text  |
            | Town or city        | text  |
            | County              | text  |
            | Postcode            | text  |

    Scenario: Submitting my data
      Given I am on the 'Enter your contact details' page for my school of choice
        And I have entered the following details into the form:
            | First name          | Philip                 |
            | Last name           | Gilbert                |
            | UK telephone number | 07765 432 100          |
            | Day                 | 01                     |
            | Month               | 01                     |
            | Year                | 2000                   |
            | Email address       | phil.gilbert@gmail.com |
            | Building and street | 221B                   |
            | Street              | Baker Street           |
            | Town or city        | London                 |
            | County              | Greater London         |
            | Postcode            | NW1 6XE                |

        When I submit the form
        Then I should be on the 'candidate subjects' page for my school of choice
