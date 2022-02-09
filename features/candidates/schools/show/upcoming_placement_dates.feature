Feature: Displaying a school's upcoming dates
    So I can learn whether or not a school will fit my needs
    As a potential candidate
    I want to see a breakdown of date and subject combinations

    Scenario: When my school has flexible dates
        Given my school of choice has 'flexible' dates
        And the school is fully-onboarded
        When I am on the profile page for the chosen school
        Then there should be no breakdown of dates at all

    Scenario: The presence of the dates list
        Given my school of choice has 'fixed' dates
        And the school is fully-onboarded
        And the school has some primary placement dates set up
        When I am on the profile page for the chosen school
        Then I should see a breakdown of upcoming dates and subjects

    Scenario: The dates list contents
        Given my school of choice has 'fixed' dates
        And the school is fully-onboarded
        And the following dates have been added:
            | Months from now | Subjects                | Phase     |
            | 1               | None                    | Primary   |
            | 1               | English, Maths, Biology | Secondary |
            | 2               | None                    | Secondary |
        When I am on the profile page for the chosen school
        Then I should see the following list of available dates, subjects and phases:
            | Months from now | Subjects                | Phase     |
            | 1               | None                    | Primary   |
            | 1               | English, Maths, Biology | Secondary |
            | 2               | All subjects            | Secondary |
