Feature: Viewing previous bookings
    To give me an oversight of past booked placements
    As a school administrator
    I want to be able see a complete list of past bookings
		
    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded
    
    Scenario: Page title
        Given I am on the 'previous bookings' page
        Then the page title should be 'Previous bookings'
    
    Scenario: Breadcrumbs
        Given I am on the 'previous bookings' page
        Then I should see the following breadcrumbs:
            | Text              | Link               |
            | Some school       | /schools/dashboard |
            | Previous bookings | None               |
            
    Scenario: List presence
        Given there are some previous bookings
        When I am on the 'previous bookings' page
        Then I should see the previous bookings listed

    Scenario: Table headings
        Given there are some previous bookings
        When I am on the 'previous bookings' page
        Then the 'bookings' table should have the following values:
			      | Heading | Value            |
            | Name    | Matthew Richards |
            | Subject | Biology          |
        And the booking date should be correct
    
    Scenario: Only viewing current school's bookings
        Given there are some previous bookings
        And there are some previous bookings belonging to other schools
        When I am on the 'previous bookings' page
        Then I should only see bookings belonging to my school

    Scenario: Open booking links
        Given there are some previous bookings
        When I am on the 'previous bookings' page
        Then every booking should contain a link to view previous booking details

    Scenario:
        Given there are no bookings
        When I am on the 'previous bookings' page
        Then I should see the text 'There are no previous bookings'
        And I should not see the bookings table