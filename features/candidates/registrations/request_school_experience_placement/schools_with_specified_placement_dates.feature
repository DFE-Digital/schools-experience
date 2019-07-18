Feature: Request a school experience placement
    So I can inform a school I would like to attend on a specified day
    As a potential candidate
    I want to pick a date from the list provided by the school

    Background:
        Given my school of choice exists
        And the school offers 'Physics, Mathematics'
        And I have completed the personal information form
        And I have completed the contact information form
        And I have completed the education form
        And I have completed the teaching preference form
        And the school I'm applying to is not flexible on dates

    Scenario: Form contents
        Given I am on the 'Request school experience placement' page for my school of choice
        When the school has 3 placements available in the upcoming weeks
        Then there should be a 'What do you want to get out of your school experience?' text area
        And the "Bookings placement date" field should contain hint "School experience is only available on the following days"

    Scenario: Radio buttons
        Given the school has 3 placements available in the upcoming weeks
        When I am on the 'Request school experience placement' page for my school of choice
        Then there should be a radio button per date the school has specified

    Scenario: Submitting my data
        Given the school has 3 placements available in the upcoming weeks
        And I am on the 'Request school experience placement' page for my school of choice
        When I choose a placement date
        And I enter 'I just love teaching!' into the 'What do you want to get out of your school experience?' text area
        And I submit the form
        Then I should be on the 'Background checks' page for my school of choice
