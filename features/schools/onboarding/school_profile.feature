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
        | Teacher training                 |                           |
        | Admin contact                    |                           |

  Scenario: Page title
    Given I am on the 'Profile' page
    Then the page title should be 'Check your answers before setting up your school experience profile'

  Scenario: Breadcrumbs
    Given I am on the 'Profile' page
    Then I should not see any breadcrumbs

  Scenario: Breadcrumbs when school is onboarded
    Given the school is fully-onboarded
    And I am on the 'Profile' page
    Then I should see the following breadcrumbs:
        | Text           | Link               |
        | Some school    | /schools/dashboard |
        | School profile | None               |

  @smoke_test
  Scenario: Viewing the profile
    Given I am on the 'Profile' page
    Then the page should have the following summary list information:
      | Full name                                  | Some school                                                                                                                                                                                                                                                 |
      | Address                                    | \d{1,} something street, M\d{1,} 2JJ                                                                                                                                                                                                                        |
      | UK telephone number                        | 01234567890                                                                                                                                                                                                                                                 |
      | Email address                              | school1@example.com                                                                                                                                                                                                                                         |
      | Fees                                       | Yes - £300.00 daily other fee                                                                                                                                                                                                                               |
      | DBS check required                         | Yes - Always require DBS check                                                                                                                                                                                                                              |
      | Individual requirements                    | Must be applying to or have applied to our, or a partner school                                                                                                                                                                                             |
      | School experience phases                   | Secondary and 16 - 18 years                                                                                                                                                                                                                                 |
      | Primary key stages                         | None                                                                                                                                                                                                                                                        |
      | Subjects                                   | Maths                                                                                                                                                                                                                                                       |
      | Description                                | We have a race track                                                                                                                                                                                                                                        |
      | School experience details                  | A really good one                                                                                                                                                                                                                                           |
      | Teacher training links                     | Yes - We run our own training. Find out more about our teacher training                                                                                                                                                                                                 |
      | Dress code                                 | Business dress and must have nice hat                                                                                                                                                                                                                       |
      | Parking                                    | Carpark next door                                                                                                                                                                                                                                           |
      | Disability and access needs                | No                                                                                                                                                                                                                                                          |
      | Show disabilities and access needs support | Yes                                                                                                                                                                                                                                                         |
      | Disability and access needs                | We offer facilities and provide an inclusive environment for students, staff and school experience candidates with disability and access needs. We're happy to discuss your disability or access needs before or as part of your school experience request. |
      | Disability Confident employer scheme       | Yes                                                                                                                                                                                                                                                         |
      | Disability and access needs policy         | https://example.com                                                                                                                                                                                                                                         |
      | Start time                                 | 8:15 am                                                                                                                                                                                                                                                     |
      | Finish time                                | 4:30 pm                                                                                                                                                                                                                                                     |
      | Flexible on times                          | No                                                                                                                                                                                                                                                          |
      | UK telephone number                        | 01234567890                                                                                                                                                                                                                                                 |
      | Email address                              | g.chalmers@springfield.edu                                                                                                                                                                                                                                  |
      | Secondary email address                    | s.skinner@springfield.edu                                                                                                                                                                                                                                   |

  Scenario: Publishing without accepting the privacy policy
      Given I click the 'Accept and set up profile' button
      Then I should see an error

  Scenario: Publishing with accepting the privacy policy
      Given I check the 'By checking this box and setting up your school experience profile' checkbox
      When I click the 'Accept and set up profile' button
      Then the page title should be "You've completed step one of onboarding"

  @smoke_test
  Scenario: Publishing with accepting the privacy policy
      Given I click the 'Accept and set up profile' button
      And I check the 'By checking this box and setting up your school experience profile' checkbox
      And I click the 'Accept and set up profile' button
      When I am on the profile page for the school
      Then I should see the following summary rows:
          | Heading                      | Value                                            |
          | Experience details           | A really good one                                |
          | School subjects              | Maths                                            |
          | School phases                | Secondary (11 to 16)                             |
          | School phases                | 16 to 18                                         |
          | School Address               | 22 something                                     |
          | DBS check info               | Yes. Always require DBS check                    |
          | Other fee info               | £300.00 Daily, Gold sovereigns\nFalconry lessons |
          | Dress code                   | Business dress\nMust have nice hat               |
          | Start and finish times       | 8:15 am to 4:30 pm                               |
          | Parking                      | Not available on site\nCarpark next door         |
          | Teacher training             | We run our own training\nFind out more about     |
     And I should see the accessability information I have entered

  Scenario: Publishing profile changes for an onboarded school
      Given my school is fully-onboarded
      And I am on the 'Profile' page
      When I click the 'Change' button for the 'Fees' row
      And I choose 'Yes' from the 'Administration costs' radio buttons
      When I submit the form
      When I have entered the following details into the form:
        | Enter the number of pounds   | 100                        |
        | Explain what the fee covers. | Nondescript administration |
        | Explain how the fee is paid  | Travelers cheques          |
      And I choose 'Daily' from the 'Is this a daily or one-off fee?' radio buttons
      When I submit the form
      # Other costs have already been setup for the school
      Then the page title should be "Other costs"
      When I submit the form
      Then I should see the text 'Your profile has been saved and published.'
      Then the page title should be "School profile"
