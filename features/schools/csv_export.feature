Feature: CSV Export
    As a school administrator
    I want to download a CSV of all bookings and placement requests
    To allow for offline record keeping

    Background:
        Given I am logged in as a DfE user
        And the school has subjects
        And my school has fully-onboarded

    Scenario: Navigating to the download screen
        Given I am on the 'schools dashboard' page
        Then there should be a section titled 'Account admin'
        And I click 'Download requests and bookings'
        Then the page's main header should be 'Download requests and bookings'

    Scenario: Downloading the CSV
        Given I am on the 'csv download' page
        Then the page's main header should be 'Download requests and bookings'
        And I should see a warning
        And I click the 'Download CSV' button
        Then I should receive a CSV
