Feature: Page not found error
    To inform me I the page I navigated to does not exist
    As a user
    I would like to see an informative error page

    Scenario: The page contents
        Given I am on the 'not_found' error page
        Then the page's main header should be 'Page not found'
        And there should be some useful hints on entering the correct URL
        And there should be an email address for support
