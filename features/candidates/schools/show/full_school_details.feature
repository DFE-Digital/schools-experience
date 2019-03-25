Feature: School show page (enhanced data)
    To help me evaluate a school
    As a potential candidate
    I want to be able to view a scohol's details

    Background:
        Given there is a school called 'Springfield Elementary'

    Scenario: Page heading
        Given I am on the profile page for the chosen school
        Then the page's main heading should be "Springfield Elementary"

    Scenario: School placement information:
        Given the school has placement information text:
            """
            Paragraph one

            Paragraph two
            """
        When I am on the profile page for the chosen school
        Then I should see the correctly-formatted school placement information

    Scenario: Education phase (singular)
        Given the phases 'Primary' and 'Secondary' exist
        And the school has is a 'Primary' school
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
