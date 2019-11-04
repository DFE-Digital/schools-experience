Feature: Filtering school search results
    To help me hone a search
    As a potential candidate
    I want to be able to narrow down search results

    Background:
        Given the phases 'Primary' and 'Secondary' exist
        Given there are some subjects

    Scenario: Filtering by Primary
        When I have searched for 'Secondary' experience in 'Manchester' and am on the results page
        Then I should see a 'Subjects' filter on the left
        And it should have the hint text 'Select all that apply'
        And it should have checkboxes for all subjects

    Scenario: Filtering by Secondary
        When I have searched for 'Primary' experience in 'Manchester' and am on the results page
        Then I should not see a 'Subjects' filter on the left

    @javascript
    Scenario: Filtering while searching by current location
        Given the subjects 'Maths' and 'Art' exist
        Given there there are schools with the following attributes:
            | Name              | Phase     | Location   | Subjects |
            | Manchester School | Secondary | Manchester | Maths    |
            | Rochdale School   | Secondary | Rochdale   | Art      |
            | Burnley School    | Primary   | Burnley    |          |
        And I have provided a point in 'Bury' as my location for 'Secondary' experience
        And I check the 'Maths' filter box
        When I click the 'Update schools list' button
        Then only schools teaching 'Maths' are visible
