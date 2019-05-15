Feature: Previewing my application
    So I can confirm the accuracy of my submission
    As a potential candidate
    I want to check my data before I submit it

    Background:
        Given my school of choice exists
        And my school of choice offers 'Physics'

    Scenario: Page contents (when the school has flexible availability)
        Given my school has flexible dates
        And I have completed the wizard
        When I am on the 'Check your answers' page for my choice of school
        Then I should see the following summary rows:
            | Heading                        | Value                                                   | Change link path                                                                                                                             |
            | Full name                      | testy mctest                                            | /candidates/schools/123456/registrations/contact_information/edit#candidates_registrations_contact_information_full_name_container           |
            | Date of birth                  | 01/01/2000                                              |                                                                                                                                              |
            | Address                        | Test house, Test street, Test Town, Testshire, TE57 1NG | /candidates/schools/123456/registrations/contact_information/edit#candidates_registrations_contact_information_building_container            |
            | UK telephone number            | 01234567890                                             | /candidates/schools/123456/registrations/contact_information/edit#candidates_registrations_contact_information_phone_container               |
            | Email address                  | test@example.com                                        | /candidates/schools/123456/registrations/contact_information/edit#candidates_registrations_contact_information_email_container               |
            | School or college              | school 1                                                |                                                                                                                                              |
            | Experience availability        | Epiphany to Whitsunday                                  | /candidates/schools/123456/registrations/placement_preference/edit#candidates_registrations_placement_preference_availability_container      |
            | Experience outcome             | I enjoy teaching                                        | /candidates/schools/123456/registrations/placement_preference/edit#candidates_registrations_placement_preference_objectives_container        |
            | Degree stage                   | Graduate or postgraduate                                | /candidates/schools/123456/registrations/subject_preference/edit#candidates_registrations_subject_preference_degree_stage_container          |
            | Degree subject                 | Physics                                                 | /candidates/schools/123456/registrations/subject_preference/edit#candidates_registrations_subject_preference_degree_stage_container          |
            | Teaching stage                 | I’m very sure and think I’ll apply                      | /candidates/schools/123456/registrations/subject_preference/edit#candidates_registrations_subject_preference_teaching_stage_container        |
            | Teaching subject first choice  | Physics                                                 | /candidates/schools/123456/registrations/subject_preference/edit#candidates_registrations_subject_preference_subject_first_choice_container  |
            | Teaching subject second choice | I don't have a second subject                           | /candidates/schools/123456/registrations/subject_preference/edit#candidates_registrations_subject_preference_subject_second_choice_container |
            | DBS certificate                | Yes                                                     | /candidates/schools/123456/registrations/background_check/edit#candidates_registrations_background_check_has_dbs_check_container             |

    Scenario: Page contents (when the school has fixed availability)
        Given my school has fixed dates
        And I have completed the wizard
        When I am on the 'Check your answers' page for my choice of school
        Then I should see a summary row containing my selected date
        And the row should have a 'Change' link to '/candidates/schools/123456/registrations/placement_preference/edit'
