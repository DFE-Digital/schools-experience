Feature: Viewing historical attendances
    To give me an oversight of historical attendance
    As a school administrator
    I want to be able see a paginated list of past attendances
		
    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded
    
    Scenario: Page title
        Given I am on the 'attendances' page
        Then the page title should be 'Attendances'
    
    Scenario: Breadcrumbs
        Given I am on the 'attendances' page
        Then I should see the following breadcrumbs:
            | Text               | Link                        |
            | Some school        | /schools/dashboard          |
            | Confirm attendance | /schools/confirm_attendance |
            | Attendances        | None                        |

    Scenario: Table headings
        Given there are some bookings with attendance recorded
        When I am on the 'attendances' page
        Then the 'attendances' table should have the following values:
			| Heading    | Value             |
            | Name       | Matthew Richards  |
            | Subject    | Biology           |
            | Date       | \d{2}\s\w+\s\d{4} |
            | Attended   | Did not attend    |

    Scenario: No attendance records
        Given there are no bookings with attendance recorded
        When I am on the 'attendances' page
        Then I should see the text 'There are no attendance records'
        And I should not see the attendances table