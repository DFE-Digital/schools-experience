Feature: Verify your email
  So I can be signed in for my placement request
  As a potential candidate
  I want to be able to provide my personal details

  Background:
    Given my school of choice exists

    Scenario: Page contents
        Given I have completed the Personal Information step for my school of choice
        And I am on the 'Verify your email' page for my school of choice
        Then the page's main header should be 'You’re already registered with us'
        And I should see an email was sent to my email address

    # Disabled these features as they will be flakey when run in parralel
    @wip
    Scenario: Confirming the Email
        Given I have completed the Personal Information step for my school of choice
        And I have a valid session token
        And I follow the verify link in the confirmation email
        Then I should be on the 'enter your contact details' page for my school of choice
