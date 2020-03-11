Feature: Service Updates
    To notify me that updates have happened to the service
    I should see a notification when there are new service updates
    Which should disappear after viewing the notification
  
    Background:
        Given I am logged in as a DfE user
        And  my school has fully-onboarded
    
    Scenario: Viewing the Dashboard
        Given I am on the 'schools dashboard' page
        Then I should see the latest service update notification
    
    Scenario: Viewing the Dashboard after viewing Service Updates
        Given I am on the 'service updates' page
        And I click 'back'
        Then I am on the 'schools dashboard' page
        And I should not see the latest service update notification