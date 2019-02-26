Feature: School search result pagination
    To help me navigate through a large number of results
    As a potential candidate
    I want to be able to browse through results by page

    Scenario: Pagination links are not displayed when there isn't a full page of results
        Given there are 6 schools in 'London'
        When I have searched for 'London' and am on the results page
        Then I should not see pagination links

    Scenario: Pagination links are displayed when there is more than one page of results
        Given there are 17 schools in 'London'
        When I have searched for 'London' and am on the results page
        Then I should see pagination links

    Scenario: Current page should not be a hyperlink
        Given there are 18 schools in 'London'
        When I have searched for 'London' and am on the results page
        Then pagination page 1 should not be a hyperlink

    Scenario: Other pages should be hyperlinks
        Given there are 18 schools in 'London'
        When I have searched for 'London' and am on the results page
        Then pagination page 2 should be a hyperlink

    Scenario: Next link
        Given there are 18 schools in 'London'
        When I have searched for 'London' and am on the results page
        Then there should be a 'Next' link in the pagination

    Scenario: Previous link
        Given there are 18 schools in 'London'
        And I have searched for 'London' and am on the results page
        When I navigate to the second page of results
        Then there should be a 'Previous' link in the pagination

    Scenario: Bottom-of-the-page navigation
        Given there are 18 schools in 'London'
        When I have searched for 'London' and am on the results page
        Then there should be 2 sets of pagination links

    Scenario: Bottom-of-the-page on last page
        Given there are 18 schools in 'London'
        When I have searched for 'London' and am on the results page
        And I navigate to the second page of results
        Then there should be 1 set of pagination links

    Scenario: Pagination description on page one
        Given there are 18 schools in 'London'
        When I have searched for 'London' and am on the results page
        Then the pagination description should say 'Showing 1–15 of 18 results'

    Scenario: Pagination description on page two
        Given there are 18 schools in 'London'
        When I have searched for 'London' and am on the results page
        And I navigate to the second page of results
        Then the pagination description should say 'Showing 16–18 of 18 results'
