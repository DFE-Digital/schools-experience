Feature: Reviewing recurrences for a placement date
  So I can manage placement dates
  As a school administrator
  I want to be able to preview and change a placement date prior to publishing it

  Background:
    Given I am logged in as a DfE user
    And my school is fully-onboarded
    And my school is a 'secondary' school
    And the school has subjects
    And I have entered a placement date
    And I have entered placement details

  Scenario: Page title
    Given the placement date is not subject specific
    Then the page's main heading should be "Check your placement details"

  Scenario: Summary table
    Given the placement date is not subject specific
    Then I should see the date summary row
    And I should see the following summary rows:
      | Heading                                           | Value                       | Change link path                                  |
      | When do you want to close this date to candidates | 0 days before the event     | /schools/placement_dates/\d+/placement_detail/new  |
      | How long will it last                             | 3 days                      | /schools/placement_dates/\d+/placement_detail/new  |
      | Experience type	                                  | In school                   | /schools/placement_dates/\d+/placement_detail/new  |
      | School phase                                      | Secondary                   | /schools/placement_dates/\d+/configuration/new     |

  Scenario: Summary table with subjects
    Given the placement date is subject specific
    And I submit the form
    Then I should see the following summary rows:
      | Heading                                           | Value                       | Change link path                                  |
      | Subjects                                          | Maths, Physics, and Biology | /schools/placement_dates/\d+/subject_selection/new |

  Scenario: Publishing the placement date
    Given the placement date is not subject specific
    When I click the "Publish placement date" button
    Then I should be on the "placement dates" page
    And my newly-created placement date should be listed
