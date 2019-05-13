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
        | Step name                    | Extra                     |
        | Candidate Requirements       |                           |
        | Fees                         | choosing only Other costs |
        | Other costs                  |                           |
        | Phases                       |                           |
        | Subjects                     |                           |
        | Description                  |                           |
        | Candidate experience details |                           |
        | Availability preference      |                           |
        | Availability description     |                           |
        | Experience Outline           |                           |
        | Admin contact                |                           |


  Scenario: Viewing the profile
    Given I am on the 'Profile' page
    Then the page should have the following summary list information:
      | Full name                   | school 1                                                    |
      | Address                     | \d{1,} something street, M\d{1,} 2JJ                        |
      | Email address               | school1@example.com                                         |
      | Fees                        | Yes - £300.00 daily other fee                               |
      | DBS check required          | Yes - Sometimes. policy details                             |
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
      | Availability                | Whenever really                                             |
      | Full name                   | Gary Chalmers                                               |
      | UK telephone number         | 01234567890                                                 |
      | Email address               | g.chalmers@springfield.edu                                  |
