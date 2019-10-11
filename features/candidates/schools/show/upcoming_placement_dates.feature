Feature: Displaying a school's upcoming dates
    So I can learn whether or not a school will fit my needs
    As a potential candidate
    I want to see a breakdown of date and subject combinations

    Scenario: When my school has flexible dates
        Given my school of choice has 'flexible' dates
        When I am on the profile page for the chosen school
        Then there should be no breakdown of dates at all

    Scenario: The presence of the dates list
        Given my school of choice has 'fixed' dates
        When I am on the profile page for the chosen school
        Then I should see a breakdown of upcoming dates and subjects

    Scenario: The dates list contents
        Given my school of choice has 'fixed' dates
        And the following dates have been added:
            | Date             | Subjects                |
            | 1 week from now  | None                    |
            | 1 week from now  | English, Maths          |
            | 2 weeks from now | English, Maths, Biology |
            | 3 weeks from now | None                    |
        When I am on the profile page for the chosen school
        Then I should see the following list of available dates and subjects:
            | Date             | Subjects                     |
            | 1 week from now  | All subjects, English, Maths |
            | 2 weeks from now | English, Maths, Biology      |
            | 3 weeks from now | All subjects                 |
