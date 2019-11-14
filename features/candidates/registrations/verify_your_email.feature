Feature: Verify your email
  So I can be signed in for my placement request
  As a potential candidate
  I want to be able to provide my personal details

  Background:
    Given my school of choice exists

    Scenario: Page contents
        Given I have completed the Personal Information step for my school of choice
        And I am on the 'Verify your email' page for my school of choice
        Then the page's main header should be 'We already have your details'
        And I should see an email was sent to my email address

    # Disabled these features as they will be flakey when run in parralel
    @wip
    Scenario: Confirming the Eamil
        Given I have completed the Personal Information step for my school of choice
        And I have a valid session token
        And I follow the verify link in the confirmation email
        Then I should be on the 'enter your contact details' page for my school of choice

    @wip
    Scenario: Confirming the Eamil
        Given the school offers 'Physics, Mathematics'
        And the school I'm applying to is not flexible on dates
        And A clear registration_store
        And I have chosen a subject specific date
        And I have completed the Personal Information step for my school of choice
        And I have a valid session token
        And I change device
        And I follow the verify link in the confirmation email
        Then I should not have been kicked back to the start of the wizard
        And I should be on the 'enter your contact details' page for my school of choice
