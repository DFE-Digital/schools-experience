Feature: Publishing Profile
  So candidates can view our latest profile
  As a school administrator
  I want to be able to publish my profile

    Background: I have completed the wizard thus far
        Given I am logged in as a DfE user
        And A school is returned from DFE sign in
        And the secondary school phase is availble
        And the college phase is availble
        And there are some subjects available
        And I have completed the following steps:
            | Step name                    | Extra                     |
            | DBS Requirements             |                           |
            | Candidate Requirements       |                           |
            | Fees                         | choosing only Other costs |
            | Other costs                  |                           |
            | Phases                       |                           |
            | Subjects                     |                           |
            | Description                  |                           |
            | Candidate experience details |                           |
            | Experience Outline           |                           |
            | Admin contact                |                           |


    Scenario: Page contents
        Then the page title should be 'Check your answers before setting up your school experience profile'
        And I should see the following summary rows:
            | Heading                     | Value                                                       |
            | Fees                        | Yes - £300.00 daily other fee                               |
            | DBS check required          | Yes - Always require DBS check                              |
            | Individual requirements     | Yes - Candidates need to be good                            |
            | School experience phases    | Secondary and 16 - 18 years                                 |
            | Primary key stages          | None                                                        |
            | Subjects                    | Maths                                                       |
            | Description                 | We have a race track                                        |
            | School experience details   | A really good one                                           |
            | Teacher training links      | Yes - We run our own training. Teacher training information |
            | Dress code                  | Business dress and must have nice hat                       |
            | Parking                     | Carpark next door                                           |
            | Disability and access needs | No                                                          |
            | Start time                  | 8:15 am                                                     |
            | Finish time                 | 4:30 pm                                                     |
            | Flexible on times           | No                                                          |

    Scenario: Publishing without accepting the privacy policy
        Given I click the 'Continue' button
        When I click the 'Accept and set up profile' button
        Then I should see an error

    Scenario: Publishing with accepting the privacy policy
        Given I click the 'Continue' button
        And I check the 'By checking this box and setting up your school experience profile you’re confirming, to the best of your knowledge, the details you’re providing are correct and you accept our' checkbox
        When I click the 'Accept and set up profile' button
        Then the page title should be "You've successfully set up your school experience profile"

    Scenario: Publishing with accepting the privacy policy
        Given I click the 'Continue' button
        And I check the 'By checking this box and setting up your school experience profile you’re confirming, to the best of your knowledge, the details you’re providing are correct and you accept our' checkbox
        And I click the 'Accept and set up profile' button
        When I am on the profile page for the school
        Then I should see the following summary rows:
            | Heading                           | Value                                            |
            | Individual requirements           | Candidates need to be good                       |
            | Experience details                | A really good one                                |
            | School subjects                   | Maths                                            |
            | School phases                     | Secondary (11 to 16) and 16 to 18                |
            | School Address                    | 22 something                                     |
            | School availability info          | No information supplied                          |
            | DBS check info                    | Yes\nAlways require DBS check                    |
            | Other fee info                    | £300.00 Daily, Gold sovereigns\nFalconry lessons |
            | Dress code                        | Business dress\nMust have nice hat               |
            | Start and finish times            | 8:15 am to 4:30 pm                               |
            | Parking                           | Not available on site\nCarpark next door         |
            | Accessibility details             | No information supplied                          |
            | School teacher training info      | We run our own training\nMore information        |
