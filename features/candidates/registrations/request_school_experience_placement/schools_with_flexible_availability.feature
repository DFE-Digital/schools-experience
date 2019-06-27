Feature: Request a school experience placement
    So I can inform a school when I'd like to attend
    As a potential candidate
    I want to submit a description of my availability to the school

    Background:
        Given the school I'm applying to is flexible on dates

    Scenario: Form contents
        Given I am on the 'Request school experience placement' page for my school of choice
        Then I should see a form with the following fields:
            | Label                                                                                 | Type     |
            | Is there anything schools need to know about your availability for school experience? | textarea |
            | What do you want to get out of your school experience?                                | textarea |

    Scenario: Submitting my data
        Given I am on the 'Request school experience placement' page for my school of choice
        And I have filled in the form with accurate data
        When I submit the form
        Then I should be on the 'Background checks' page for my school of choice
