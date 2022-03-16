Feature: Unprocessable entity error page
    To inform me something I have done may not have been saved
    As a user
    I would like to see an informative error page

    Scenario: The page contents
        Given I am on the 'unprocessable_entity' error page
        Then the page's main header should be 'We were unable to process this request'
        And there should be an email address for support
