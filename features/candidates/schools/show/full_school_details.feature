Feature: School show page (enhanced data)
    To help me evaluate a school
    As a potential candidate
    I want to be able to view a school's details

    Background:
        Given there is a school called 'Springfield Elementary'
        And the school has created their profile

    Scenario: Page heading
        Given I am on the profile page for the chosen school
        Then the page's main heading should be "Springfield Elementary"

    Scenario: School profile description details
        Given the school profile has description details text:
            """
            Paragraph one

            Paragraph two
            """
        When I am on the profile page for the chosen school
        Then I should see the correctly-formatted school placement information

    Scenario: Education phase (singular)
        Given the phases 'Primary' and 'Secondary' exist
        And the school is a 'Primary' school
        When I am on the profile page for the chosen school
        Then the age range should be 'Primary'

    Scenario: Education phase (Multiple)
        Given the phases 'Primary' and 'Secondary' exist
        And the school is a 'Primary' and 'Secondary' school
        When I am on the profile page for the chosen school
        Then the age range should be 'Primary and Secondary'

    Scenario: Subjects
        Given some subjects exist
        And the school offers 3 subjects
        When I am on the profile page for the chosen school
        Then all of the subjects should be listed

    Scenario: School website
        Given the school's website is 'https://www.altervista.com'
        When I am on the profile page for the chosen school
        Then I should see a hyperlink to the school's website

    Scenario: Other websites
        Given my chosen school has the URN 999999
        When I am on the profile page for the chosen school
        Then I should see the following websites listed:
            | description                   | url                                                                                        |
            | Get Information About Schools | https://get-information-schools.service.gov.uk/Establishments/Establishment/Details/999999 |
            | Ofsted report                 | http://www.ofsted.gov.uk/oxedu_providers/full/(urn)/999999                                 |
            | Performance information       | https://www.compare-school-performance.service.gov.uk/school/999999                        |

    Scenario: Address (sidebar)
        Given I am on the profile page for the chosen school
        Then I should see the entire school address in the sidebar

    Scenario: Placement availability (sidebar)
        Given the chosen school has the following availability information
            """
            Paragraph one

            Paragraph two
            """
        When I am on the profile page for the chosen school
        Then I should see availability information in the sidebar

    Scenario: Placement availability (sidebar)
        Given the chosen school has no availability information
        When I am on the profile page for the chosen school
        Then the availability information in the sidebar should read 'No information supplied'
    
    Scenario: DBS Check info (sidebar)
        Given I am on the profile page for the chosen school
        Then the DBS Check information in the sidebar should read 'No - Candidates will be accompanied at all times'
    
    Scenario: Admin Fees information (sidebar)
        Given the school charges a 'administration' fee of '10.00' for 'general overheads'
        When I am on the profile page for the chosen school
        Then I should see the fee information
    
    Scenario: No Admin Fees information (sidebar)
        Given the school does not charge a 'administration' fee
        When I am on the profile page for the chosen school
        Then I should not see the fee information

    Scenario: DBS Fees information (sidebar)
        Given the school charges a 'dbs' fee of '10.00' for 'general overheads'
        When I am on the profile page for the chosen school
        Then I should see the fee information
    
    Scenario: No DBS Fees information (sidebar)
        Given the school does not charge a 'dbs' fee
        When I am on the profile page for the chosen school
        Then I should not see the fee information

    Scenario: Other Fees information (sidebar)
        Given the school charges a 'other' fee of '10.00' for 'general overheads'
        When I am on the profile page for the chosen school
        Then I should see the fee information
    
    Scenario: No Other Fees information (sidebar)
        Given the school does not charge a 'other' fee
        When I am on the profile page for the chosen school
        Then I should not see the fee information

    Scenario: Dress code information (sidebar)
        Given the school has a dress code policy
        When I am on the profile page for the chosen school
        Then I should see the dress code policy information

    Scenario: Teacher training offered (sidebar)
        Given the chosen school offers teacher training and has the following info
            """
            Paragraph one

            Paragraph two
            """
        When I am on the profile page for the chosen school
        Then I should see teacher training information information in the sidebar
        And the teacher training website should be listed with the other hyperlinks

    Scenario: Request placement button
        Given I am on the profile page for the chosen school
        Then there should be a button called 'Start request' that begins the wizard
