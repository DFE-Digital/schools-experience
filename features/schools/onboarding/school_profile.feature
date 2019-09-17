Feature: School Profile
  So I can ensure the data I've entered is accurate
  As a school administrator
  I want to be able to view my school profile

  Background: I have completed the wizard thus far
    Given I am logged in as a DfE user
    And A school is returned from DFE sign in
    And the secondary school phase is availble
    And the college phase is availble
    And there are some subjects available
    And I have completed the following steps:
        | Step name                        | Extra                     |
        | DBS Requirements                 |                           |
        | Candidate Requirements choice    |                           |
        | Candidate Requirements selection |                           |
        | Fees                             | choosing only Other costs |
        | Other costs                      |                           |
        | Phases                           |                           |
        | Subjects                         |                           |
        | Description                      |                           |
        | Candidate experience details     |                           |
        | Access needs support             |                           |
        | Access needs detail              |                           |
        | Disability confident             |                           |
        | Access needs policy              |                           |
        | Experience Outline               |                           |
        | Admin contact                    |                           |

  Scenario: Page title
    Given I am on the 'Profile' page
    Then the page title should be 'Check your answers before setting up your school experience profile'

  Scenario: Breadcrumbs
    Given I am on the 'Profile' page
    Then I should see the following breadcrumbs:
        | Text                                                                | Link               |
        | Some school                                                         | /schools/dashboard |
        | Check your answers before setting up your school experience profile | None               |

  Scenario: Viewing the profile
    Given I am on the 'Profile' page
    Then the page should have the following summary list information:
      | Full name                                 | Some school                                                                                                                                                                                                                                                          |
      | Address                                   | \d{1,} something street, M\d{1,} 2JJ                                                                                                                                                                                                                                 |
      | UK telephone number                       | 01234567890                                                                                                                                                                                                                                                          |
      | Email address                             | school1@example.com                                                                                                                                                                                                                                                  |
      | Fees                                      | Yes - £300.00 daily other fee                                                                                                                                                                                                                                        |
      | DBS check required                        | Yes - Always require DBS check                                                                                                                                                                                                                                       |
      | Individual requirements                   | Must be applying to or have applied to our, or a partner school's, teacher training course. They must live within 7 miles from the school. Some detail                                                                                                               |
      | School experience phases                  | Secondary and 16 - 18 years                                                                                                                                                                                                                                          |
      | Primary key stages                        | None                                                                                                                                                                                                                                                                 |
      | Subjects                                  | Maths                                                                                                                                                                                                                                                                |
      | Description                               | We have a race track                                                                                                                                                                                                                                                 |
      | School experience details                 | A really good one                                                                                                                                                                                                                                                    |
      | Teacher training links                    | Yes - We run our own training. Teacher training information                                                                                                                                                                                                          |
      | Dress code                                | Business dress and must have nice hat                                                                                                                                                                                                                                |
      | Parking                                   | Carpark next door                                                                                                                                                                                                                                                    |
      | Disability and access needs               | No                                                                                                                                                                                                                                                                   |
      | Show disabilites and access needs support | Yes                                                                                                                                                                                                                                                                  |
      | Disability and access needs               | We offer facilities and provide an inclusive environment for students, staff and school experience candidates with disability and access needs. We're happy to discuss your disability or access needs before or as part of your school experience request.          |
      | Disability Confident employer scheme      | Yes                                                                                                                                                                                                                                                                  |
      | Disability and access needs policy        | https://example.com                                                                                                                                                                                                                                                  |
      | Start time                                | 8:15 am                                                                                                                                                                                                                                                              |
      | Finish time                               | 4:30 pm                                                                                                                                                                                                                                                              |
      | Flexible on times                         | No                                                                                                                                                                                                                                                                   |
      | UK telephone number                       | 01234567890                                                                                                                                                                                                                                                          |
      | Email address                             | g.chalmers@springfield.edu                                                                                                                                                                                                                                           |
      | Secondary email address                   | s.skinner@springfield.edu                                                                                                                                                                                                                                            |

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
            | Heading                           | Value                                                                                                                                                   |
            | Individual requirements           | Must be applying to or have applied to our, or a partner school's, teacher training course. They must live within 7 miles from the school. Some details |
            | Experience details                | A really good one                                                                                                                                       |
            | School subjects                   | Maths                                                                                                                                                   |
            | School phases                     | Secondary (11 to 16) and 16 to 18                                                                                                                       |
            | School Address                    | 22 something                                                                                                                                            |
            | School availability info          | No information supplied                                                                                                                                 |
            | DBS check info                    | Yes\nAlways require DBS check                                                                                                                           |
            | Other fee info                    | £300.00 Daily, Gold sovereigns\nFalconry lessons                                                                                                        |
            | Dress code                        | Business dress\nMust have nice hat                                                                                                                      |
            | Start and finish times            | 8:15 am to 4:30 pm                                                                                                                                      |
            | Parking                           | Not available on site\nCarpark next door                                                                                                                |
            | School teacher training info      | We run our own training\nMore information                                                                                                               |

       And I should see the accessability information I have entered
