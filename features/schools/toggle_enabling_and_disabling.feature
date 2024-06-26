Feature: Toggling being enabled and disabled
    So I can prevent being overloaded by new requests
    As a school administrator
    I want to be able to toggle the enabled flag

    Background:
        Given I am logged in as a DfE user
        And my school is fully-onboarded

    Scenario: Page title
        Given I am on the 'toggle requests' page
        Then the page title should be 'Turn profile on or off'

    Scenario: Page contents
        Given I am on the 'toggle requests' page
        Then I should see radio buttons for 'Turn profile on or off' with the following options:
            | Turn profile on to allow requests        |
            | Turn profile off |

    Scenario: Disabling an enabled school
        Given my school is enabled
        And I am on the 'toggle requests' page
        When I choose 'Turn profile off' from the 'Turn profile on or off' radio buttons
        And I submit the form
        Then I should be on the 'schools dashboard' page
        And my school should be disabled

    Scenario: Enabling a disabled school
        Given my school is disabled
        And I am on the 'toggle requests' page
        When I choose 'Turn profile on to allow requests' from the 'Turn profile on or off' radio buttons
        And I submit the form
        Then I should be on the 'schools dashboard' page
        And my school should be enabled
