Feature: Preview profile
    So I know how my profile will appear to candidates
    As a school administrator
    I want to be able to see a preview of my profile before publishing it

    Background: I have completed the wizard
        Given the primary phase is available
        Given the secondary school phase is availble
        Given the college phase is availble

        And A school is returned from DFE sign in
        And I am logged in as a DfE user
        And the school has subjects
        And I have completed the following steps:
            | Step name                    | Extra                     |
            | Candidate Requirements       |                           |
            | Fees                         | choosing only Other costs |
            | Other costs                  |                           |
            | Phases                       |                           |
            | Subjects                     |                           |
            | Description                  |                           |
            | Candidate experience details |                           |
            | Experience Outline           |                           |
            | Admin contact                |                           |
        When I click the 'Preview' button

    Scenario: Page contents
        Then I should see the correctly-formatted school placement information I entered in the wizard
        And the age range should match what I entered in the wizard
        And all of the subjects I entered should be listed
        And I should see the teacher trainning info I entered in the wizard
        And I should see the following websites listed:
            | description                   | url                                                                                        |
            | Get Information About Schools | https://get-information-schools.service.gov.uk/Establishments/Establishment/Details/123456 |
            | Ofsted report                 | http://www.ofsted.gov.uk/oxedu_providers/full/(urn)/123456                                 |
            | Performance information       | https://www.compare-school-performance.service.gov.uk/school/123456                        |
        And I should see the entire school address in the sidebar
        And I should see the schools availability information in the sidebar
        And the DBS Check information in the sidebar should match the information entered in the wizard
        And I should see the fee information I entered in the wizard
        And I should see the dress code policy information I entered in the wizard
