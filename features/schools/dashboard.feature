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
        And I should see a 'Complete your school profile' link to the 'profile' page

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

    Scenario: Displaying the managing requests panel when schools have onboarded
        Given my school has fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see the managing requests panel

    Scenario: Active requests
        Given my school has fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see the following 'requests' links:
            | Text            | Hint | Path                        |
            | Manage requests | None | /schools/placement_requests |

    Scenario: Upcoming Bookings panel
        Given my school has fully-onboarded
        And it has 'fixed' availability
        When I am on the 'schools dashboard' page
        Then I should see the following 'bookings' links:
            | Text                       | Hint                                                        | Path                        |
            | Manage upcoming bookings   | None                                                        | /schools/bookings           |
            | Confirm booking attendance | Confirm if candidates have attended their school experience | /schools/confirm_attendance |

    Scenario: School profile panel
        Given my school has fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see the following 'profile' links:
            | Text                  | Hint | Path                         |
            | Update school profile | None | /schools/on_boarding/profile |
            | Turn profile on/off   | None | /schools/toggle_enabled/edit |

    Scenario: Adding, removing and changing dates visible when fixed and dates present
        Given my school has fully-onboarded
        And my school has 3 placement dates
        And it has 'fixed' availability
        When I am on the 'schools dashboard' page
        Then I should see the following 'dates' links:
            | Text                                     | Hint | Path                                  |
            | Manage dates                             | None | /schools/placement_dates              |
            | Change how available dates are displayed | None | /schools/availability_preference/edit |

    Scenario: Adding, removing and changing dates not visible when not fixed and dates not present
        Given my school has fully-onboarded
        And it has 'fixed' availability
        When I am on the 'schools dashboard' page
        Then I should see the following 'dates' links:
            | Text                                     | Hint | Path                                  |
            | Manage dates                             | None | /schools/placement_dates              |
            | Change how available dates are displayed | None | /schools/availability_preference/edit |

    Scenario: History panel
        Given my school has fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see the following 'history' links:
            | Text               | Hint | Path                        |
            | Withdrawn requests | None | /schools/withdrawn_requests |
            | Rejected requests  | None | /schools/rejected_requests  |
            | Previous bookings  | None | /schools/previous_bookings  |

    Scenario: Show the Help and support panel if schools is onboarded
        Given my school has fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see the following 'help-and-support' links:
            | Text                                   | Hint                                                                | Path                                 |
            | Request access to another organisation | Request access to manage school experience for another organisation | /schools/organisation_access_request |
            | Contact us                             | Get in touch if you need help using the service                     | /schools/contact_us                  |

    Scenario: Show the Help and support panel if schools is not onboarded
        When I am on the 'schools dashboard' page
        Then I should see the following 'help-and-support' links:
            | Text                                   | Hint                                                                | Path                                 |
            | Request access to another organisation | Request access to manage school experience for another organisation | /schools/organisation_access_request |
            | Contact us                             | Get in touch if you need help using the service                     | /schools/contact_us                  |
    
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
        Then there should be no 'Turn profile on/off' link

    Scenario: Show the enable/disable link when schools are onboarded
        Given my school has fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see a 'Turn profile on/off' link to the 'toggle requests' page

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
