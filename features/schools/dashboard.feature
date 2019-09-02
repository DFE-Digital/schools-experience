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

    Scenario: Displaying the managing requests section when schools have onboarded
        Given my school has fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see the managing requests section

    Scenario: To-do list
        Given my school has fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see the following 'high-priority' links:
            | Text            | Hint                                        | Path                        |
            | Manage requests | Candidates have requested school experience | /schools/placement_requests |
            | Manage bookings | A candidate has asked to change a booking   | /schools/bookings           |

    Scenario: Manage dates (fixed dates)
        Given my school has fully-onboarded
        And it has 'fixed' availability
        When I am on the 'schools dashboard' page
        Then I should see the following 'medium-priority' links:
            | Text                           | Hint | Path                                  |
            | Add, remove and change dates   | None | /schools/placement_dates              |
            | Change how dates are displayed | None | /schools/availability_preference/edit |

    Scenario: Manage dates (flexible dates)
        Given my school has fully-onboarded
        And it has 'flexible' availability
        When I am on the 'schools dashboard' page
        Then I should see the following 'medium-priority' links:
            | Text                                                   | Hint | Path                                  |
            | Describe when you’ll host school experience candidates | None | /schools/availability_info/edit       |
            | Change how dates are displayed                         | None | /schools/availability_preference/edit |

    Scenario: Account admin
        Given my school has fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see the following 'medium-priority' links:
            | Text                   | Hint                                                      | Path                         |
            | Update school profile  | Add, edit and remove school profile details               | /schools/on_boarding/profile |
            | Turn requests on / off | Choose to stop / start receiving requests from candidates | /schools/toggle_enabled/edit |

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
        And there are 3 new bookings
        When I am on the 'schools dashboard' page
        Then the 'new bookings counter' should be 3

    Scenario: Confirm attendance counter
        Given my school has fully-onboarded
        And there are 2 bookings in the past with no attendance logged
        When I am on the 'schools dashboard' page
        Then the 'confirm attendance counter' should be 2

    Scenario: Hide the enable/disable link if schools not onboarded
        Given my school has not yet fully-onboarded
        When I am on the 'schools dashboard' page
        Then there should be no 'Turn requests on / off' link

    Scenario: Show the enable/disable link when schools are onboarded
        Given my school has fully-onboarded
        When I am on the 'schools dashboard' page
        Then I should see a 'Turn requests on / off' link to the 'toggle requests' page

    Scenario: Displaying a warning when fixed with no dates
        Given my school has fully-onboarded
        And it has 'fixed' availability
        And my school has no placement dates
        When I am on the 'schools dashboard' page
        Then there should be a 'You have no placement dates' warning

    Scenario: Displaying a warning when flexible with no description
        Given my school has fully-onboarded
        And it has 'flexible' availability
        And my school has availability no information set
        When I am on the 'schools dashboard' page
        Then there should be a 'You have no availability information' warning
