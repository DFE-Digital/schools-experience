Feature: Viewing withdrawn requests
    To give me an view of the requests which have been cancelled by the candidate
    As a school administrator
    I want to be able see a complete list of withdrawn requests
		
    Background:
        Given I am logged in as a DfE user
        And my school has fixed dates
        And my school is fully-onboarded
    
    Scenario: Page title
        Given I am on the 'withdrawn requests' page
        Then the page title should be 'Withdrawn requests'
    
    Scenario: Breadcrumbs
        Given I am on the 'withdrawn requests' page
        Then I should see the following breadcrumbs:
            | Text               | Link               |
            | Some school        | /schools/dashboard |
            | Withdrawn requests | None               |
            
    Scenario: List presence
        Given there are some withdrawn requests
        When I am on the 'withdrawn requests' page
        Then I should see the withdrawn requests listed

    Scenario: Table headings
        Given there are some withdrawn requests
        When I am on the 'withdrawn requests' page
        Then the 'withdrawn-requests' table should have the following values:
			      | Heading | Value            |
            | Name    | Matthew Richards |
            | Subject | Not specified    |
        And the withdrawn requests date should be correct
    
    Scenario: Only viewing current school's requests
        Given there are some withdrawn requests
        And there are some withdrawn requests belonging to other schools
        When I am on the 'withdrawn requests' page
        Then I should only see withdrawn requests belonging to my school

    Scenario: Open request links
        Given there are some withdrawn requests
        When I am on the 'withdrawn requests' page
        Then every withdrawn request should contain a link to view more details

    Scenario:
        Given there are no withdrawn requests
        When I am on the 'withdrawn requests' page
        Then I should see the text 'There are no withdrawn requests'
        And I should not see the requests table
