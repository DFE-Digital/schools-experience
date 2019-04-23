Feature: Request a school experience placement
    So I can inform a school I would like to attend on a specified day
    As a potential candidate
    I want to pick a date from the list provided by the school

    Background:
        Given the school I'm applying to is not flexible on dates

    Scenario: Form contents
        Given I am on the 'Request school experience placement' page for my school of choice
        When the school has 3 placements available in the upcoming weeks
        Then there should be a 'What do you want to get out of your school experience?' text area

    Scenario: Radio buttons
        Given the school has 3 placements available in the upcoming weeks
        When I am on the 'Request school experience placement' page for my school of choice
        Then there should be a radio button per date the school has specified
