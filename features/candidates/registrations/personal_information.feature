Feature: Personal Information
  So I can potentially be signed in for my placement request
  As a potential candidate
  I want to be able to provide my personal details

    Scenario: Page contents
        Given I am on the 'Enter your personal details' page for my school of choice
        Then the page's main header should be 'Check if we already have your details'
        And I should see a paragraph informing me that my details will be used to identify me

    Scenario: Form contents
        Given I am on the 'Enter your personal details' page for my school of choice
        Then I should see a form with the following fields:
            | Label               | Type  |
            | First name          | text  |
            | Last name           | text  |
            | Email address       | email |

    Scenario: Submitting my data with unknown Candidate
      Given I am on the 'Enter your personal details' page for my school of choice
        And I have entered the following details into the form:
            | First name          | Philip                 |
            | Last name           | Gilbert                |
            | Email address       | phil.unknown@gmail.com |

        When I submit the form
        Then I should be on the 'enter your contact details' page for my school of choice

    Scenario: Submitting my data with known Candidate
      Given I am on the 'Enter your personal details' page for my school of choice
        And I have entered the following details into the form:
            | First name          | Philip                 |
            | Last name           | Gilbert                |
            | Email address       | phil.gilbert@gmail.com |

        When I submit the form
        Then I should be on the 'verify your email' page for my school of choice