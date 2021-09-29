Feature: The School Dashboard
    To help me gain an insight into tasks that need to be addressed
    As a school administrator
    I want to be able see a high-level view of tasks

    Background:
        Given I am logged in as a DfE user
        And the school has subjects

    Scenario: Site header
        Given I am on the 'schools dashboard' page
        Then the main site header should be 'Manage school experience'

    Scenario: Hiding the managing requests section when schools haven't onboarded
        Given my school has not yet fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see a warning informing me that I need to complete my profile before continuing
        And I should see a 'Update your school profile' link to the 'profile' page

    Scenario: Displaying a warning when the school is disabled
        Given my school has fully-onboarded
        And my school is disabled
        When I am on the 'schools dashboard' page
        Then I should see a warning that my school is disabled

    Scenario: Displaying no warning when the school is enabled
        Given my school has fully-onboarded
        And my school is enabled
        When I am on the 'schools dashboard' page
        Then I shouldn't see any warnings

    Scenario: Displaying the managing requests section when schools have onboarded
        Given my school has fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see the managing requests section

    Scenario: To-do list
        Given my school has fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see the following 'high-priority' links:
            | Text            | Hint                                           | Path                        |
            | Manage requests | View, accept and decline requests | /schools/placement_requests |
            | Manage upcoming bookings | View, change or cancel bookings                | /schools/bookings           |

    Scenario: Manage dates
        Given my school has fully-onboarded
        And it has 'fixed' availability
        When I am on the 'schools dashboard' page
        Then I should see the following 'medium-priority' links:
            | Text                                   | Hint | Path                                  |
            | Change how dates are displayed | Show specific dates, or a description of when you can host candidates | /schools/availability_preference/edit |

    Scenario: Adding, removing and changing dates visible when fixed and dates present
        Given my school has fully-onboarded
        And my school has 3 placement dates
        And it has 'fixed' availability
        When I am on the 'schools dashboard' page
        Then I should see the following 'medium-priority' links:
            | Text                                   | Hint | Path                                  |
            | Change how dates are displayed | Show specific dates, or a description of when you can host candidates | /schools/availability_preference/edit |
            | Manage dates           | Add, remove and change placement dates | /schools/placement_dates              |

    Scenario: Adding, removing and changing dates not visible when not fixed and dates not present
        Given my school has fully-onboarded
        And it has 'fixed' availability
        When I am on the 'schools dashboard' page
        Then I should see the following 'medium-priority' links:
            | Text                                   | Hint | Path                                  |
            | Change how dates are displayed | Show specific dates, or a description of when you can host candidates | /schools/availability_preference/edit |
            | Manage dates           | Add, remove and change placement dates | /schools/placement_dates              |


    Scenario: Account admin
        Given my school has fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see the following 'medium-priority' links:
            | Text                           | Hint                                                                    | Path                         |
            | View rejected requests         | View request dates, subjects, candidate names and reasons for rejection | /schools/rejected_requests   |
            | View previous bookings         | View booking dates, subjects, candidate names and attendance         | /schools/previous_bookings   |
            | Download requests and bookings | Download all requests and bookings as a CSV file                        | /schools/csv_export          |
            | Update school profile          | Update school details, placement details and requirements                             | /schools/on_boarding/profile |
            | Switch profile on or off         | Choose to stop / start receiving requests from candidates               | /schools/toggle_enabled/edit |

    Scenario: Low priority headings
        Given my school has fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see the following 'low-priority' links:
            | Text       | Hint                                            | Path                |
            | Contact us | Get in touch if you need help using the service | /schools/contact_us |

    Scenario: Candidate requests counter
        Given my school has fully-onboarded
        And there are 5 new requests
        When I am on the 'schools dashboard' page
        Then the 'new requests counter' should be 5

    Scenario: Candidate bookings counter
        Given my school has fully-onboarded
        And there are 3 unviewed candidate cancellations
        When I am on the 'schools dashboard' page
        Then the 'new bookings counter' should be 3

    Scenario: Confirm attendance counter
        Given my school has fully-onboarded
        And there are 2 bookings in the past with no attendance logged
        And there is a booking in the past that has been cancelled
        When I am on the 'schools dashboard' page
        Then the 'confirm attendance counter' should be 2

    Scenario: Hide the enable/disable link if schools not onboarded
        Given my school has not yet fully-onboarded
        When I am on the 'schools dashboard' page
        Then there should be no 'Switch profile on or off' link

    Scenario: Show the enable/disable link when schools are onboarded
        Given my school has fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see a 'Switch profile on or off' link to the 'toggle requests' page

    Scenario: Displaying a warning when fixed with no dates
        Given my school has fully-onboarded
        And it has 'fixed' availability
        And my school has no placement dates
        When I am on the 'schools dashboard' page
        Then there should be a "You haven't entered any dates" warning

    Scenario: Displaying a warning when flexible with no description
        Given my school has fully-onboarded
        And it has 'flexible' availability
        And my school has availability no information set
        When I am on the 'schools dashboard' page
        Then there should be a 'You have no availability information' warning
