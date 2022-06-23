Feature: Contact Information
  So I can be contacted about my placement request
  As a potential candidate
  I want to be able to provide my contact details

    Background:
        Given my school of choice exists
        Given I have completed the personal information form

    Scenario: Page contents
        Given I am on the 'Enter your contact details' page for my school of choice
        Then the page's main header should be 'Enter your contact details'
        And I should see a paragraph informing me that my details will be used by schools to contact me

    Scenario: Form contents
        Given I am on the 'Enter your contact details' page for my school of choice
        Then I should see a form with the following fields:
            | Label                     | Type | Autocompletion |
            | UK telephone number       | tel  | on             |
            | Address line 1            | text | address-line1  |
            | Address line 2 (optional) | text | address-line2  |
            | Town or city (optional)   | text | address-level2 |
            | County (optional)         | text | address-level1 |
            | Postcode                  | text | postal-code    |

    Scenario: Submitting my data
      Given I am on the 'Enter your contact details' page for my school of choice
        And I have entered the following details into the form:
            | UK telephone number       | 01234567890    |
            | Address line 1            | 221B           |
            | Address line 2 (optional) | Baker Street   |
            | Town or city (optional)   | London         |
            | County (optional)         | Greater London |
            | Postcode                  | NW1 6XE        |
            | UK telephone number       | 07765 432 100  |

        When I submit the form
        Then I should be on the 'education' page for my school of choice
