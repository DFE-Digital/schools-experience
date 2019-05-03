Feature: School Profile
  So I can ensure the data I've entered is accurate
  As a school administrator
  I want to be able to view my school profile

  Background: I have completed the wizard thus far
    Given I am logged in as a DfE user
    Given A school is returned from DFE sign in
    Given The secondary school phase is availble
    Given The college phase is availble
    And There are some subjects available
    And I have completed the Candidate Requirements step
    And I have completed the Fees step, choosing only Other costs
    And I have completed the Other costs step
    And I have completed the Phases step
    And I have completed the Subjects step
    And I have completed the Specialisms step
    And I have completed the Candidate experience details step
    And I have completed the Availability preference step
    And I have completed the Availability description step
    And I have completed the Experience Outline step
    And I have completed the Admin contact

  Scenario: Viewing the profile
    Given I am on the 'Profile' page
    Then The page should have the following summary list information:
      | Full name                   | school 1                                          |
      | Address                     | \d{1,} something street, M\d{1,} 2JJ              |
      | Email address               | school1@example.com                               |
      | Fees                        | Yes - £300.00 daily other fee                     |
      | DBS check required          | Yes - Sometimes. policy details                   |
      | Individual requirements     | Yes - Candidates need to be good                  |
      | School experience phases    | secondary and 16 - 18 years                       |
      | Primary key stages          | None                                              |
      | Subjects                    | Maths                                             |
      | Specialisms                 | Yes - Race track                                  |
      | School experience details   | A really good one                                 |
      | Teacher training links      | Yes - We run our own training. http://example.com |
      | Dress code                  | business dress and Must have nice hat             |
      | Parking                     | Carpark next door                                 |
      | Disability and access needs | No                                                |
      | Start time                  | 8:15 am                                           |
      | Finish time                 | 4:30 pm                                           |
      | Flexible on times           | Yes                                               |
      | Availability                | Whenever really                                   |
      | Full name                   | Gary Chalmers                                     |
      | UK telephone number         | 01234567890                                       |
      | Email address               | g.chalmers@springfield.edu                        |
