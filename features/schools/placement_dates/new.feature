Feature: Creating new placement dates
    So I can add placement dates
    As a school administrator
    I want to be able to specify and create dates

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded

    Scenario: Page title
        Given I am on the 'new placement date' page
        Then the page title should be 'Add a date'

    Scenario: Breadcrumbs
        Given I am on the 'new placement date' page
        Then I should see the following breadcrumbs:
            | Text                    | Link                     |
            | Some school             | /schools/dashboard       |
            | Placement dates         | /schools/placement_dates |
            | Create a placement date | None                     |

    Scenario: Placement date form
        Given I am on the 'new placement date' page
        Then I should see a form with the following fields:
            | Label                  | Type   |
            | Enter start date       | date   |
            | How long will it last? | number |

    Scenario: Preventing invalid dates from being added
        Given I am on the 'new placement date' page
        And I fill in the 'Enter start date' date field with an invalid date of 31st September next year
        When I submit the form
        Then I should see an error message stating 'Enter a valid date'

    Scenario: Filling in and submitting the form
        Given my school is a 'primary' school
        And I am on the 'new placement date' page
        When I fill in the form with a future date and duration of 3
        And I submit the form
        Then I should be on the 'placement dates' page

    Scenario: Primary and secondary schools: extra option
        Given my school is a 'primary and secondary' school
        And I am on the 'new placement date' page
        Then I should see radio buttons for 'Select school experience phase' with the following options:
          | Primary including early years, key stage 1 and key stage 2                      |
          | Secondary including secondary schools, sixth-forms, colleges and 16 to 18 years |

    Scenario: Primary and secondary schools: selecting primary
        Given my school is a 'primary and secondary' school
        And I am on the 'new placement date' page
        When I fill in the form with a future date and duration of 3
        And I choose 'Primary including early years, key stage 1 and key stage 2' from the 'Select school experience phase' radio buttons
        And I submit the form
        Then I should be on the 'placement dates' page

    Scenario: Primary and secondary schools: selecting secondary
        Given my school is a 'primary and secondary' school
        And I am on the 'new placement date' page
        When I fill in the form with a future date and duration of 3
        And I choose 'Secondary including secondary schools, sixth-forms, colleges and 16 to 18 years' from the 'Select school experience phase' radio buttons
        And I submit the form
        Then I should be on the new configuration page for my placement date
        And there should be a subject specificity option
