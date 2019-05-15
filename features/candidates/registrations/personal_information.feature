Feature: Personal Information
  So I can potentially be signed in for my placement request
  As a potential candidate
  I want to be able to provide my personal details

    Scenario: Page contents
        Given I am on the 'Enter your personal details' page for my school of choice
        Then the page's main header should be 'Enter your personal details'
        And I should see a paragraph informing me that my details will be used by schools to contact me

    Scenario: Form contents
        Given I am on the 'Enter your personal details' page for my school of choice
        Then I should see a form with the following fields:
            | Label               | Type  |
            | First name          | text  |
            | Last name           | text  |
            | Email address       | email |
            | Date of birth       | date  |

    Scenario: Submitting my data
      Given I am on the 'Enter your personal details' page for my school of choice
        And I have entered the following details into the form:
            | First name          | Philip                 |
            | Last name           | Gilbert                |
            | Email address       | phil.gilbert@gmail.com |
            | Day                 | 01                     |
            | Month               | 01                     |
            | Year                | 2000                   |

        When I submit the form
        Then I should be on the 'enter your contact details' page for my school of choice
