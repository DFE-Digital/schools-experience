Feature: Page not found error page
    To inform me that there is a problem with the service
    As a user
    I would like to see an informative error page

    Scenario: The page contents
        Given I am on the 'internal_server_error' error page
        Then the page's main header should be 'Sorry, there is a problem with the service'
        And there should be some text explaining technical difficulties
        And there should be an email address for support
