Feature: School Chooser
    To select the school I wish to administer

    Background:
        Given the School Chooser feature is enabled
        And I have two schools
        And I am logged in as a DfE user
    
    @mocks
    Scenario: Signing in
        Given I go to the 'schools dashboard' page
        Then I should be on the 'school chooser' page
        Then I should see radio buttons for 'Select your school' with the following options:
            | School A |
            | School B |
        But no radio buttons should be selected
        Then I choose 'School A' from the 'Select your school' radio buttons
        And I click the 'Choose school' submit button
        Then I should be on the 'schools dashboard' page
        Then the page's main heading should be 'Manage requests and bookings at School A'
    
    @mocks
    Scenario: Changing school
        Given I am signed in as School A
        And I am on the 'schools dashboard' page
        Then the page's main heading should be 'Manage requests and bookings at School A'
        And I click 'Change school'
        Then I should be on the 'school chooser' page
        Then I should see radio buttons for 'Select your school' with the following options:
            | School A |
            | School B |
        And 'School A' radio button should be selected
        Then I choose 'School B' from the 'Select your school' radio buttons
        And I click the 'Choose school' submit button
        Then I should be on the 'schools dashboard' page
        Then the page's main heading should be 'Manage requests and bookings at School B'
        
