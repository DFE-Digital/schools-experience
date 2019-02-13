FactoryBot.define do
  factory :registration_session, class: Candidates::Registrations::RegistrationSession do
    initialize_with do
      current_time = DateTime.current
      new \
        "registration" => {
          "candidates_registrations_account_check" => {
            "full_name" => 'Testy McTest',
            "email" => 'test@example.com',
            "created_at" => current_time,
            "updated_at" => current_time
          },
          "candidates_registrations_address" => {
            "building" => "Test building",
            "street" => "Test street",
            "town_or_city" => "Test town",
            "county" => "Testshire",
            "postcode" => "TE57 1NG",
            "phone" => "01234567890",
            "created_at" => current_time,
            "updated_at" => current_time
          },
          "candidates_registrations_background_check" => {
            "has_dbs_check" => true,
            "created_at" => current_time,
            "updated_at" => current_time
          },
           "candidates_registrations_placement_preference" => {
            "date_start" => (current_time + 3.day),
            "date_end" => (current_time + 4.days),
             "objectives" => "test the software",
             "access_needs" => false,
             "access_needs_details" => "",
             "created_at" => current_time,
             "updated_at" => current_time
          },
           "candidates_registrations_subject_preference" => {
             "degree_stage" => "I don't have a degree and am not studying for one",
             "degree_stage_explaination" => "",
             "degree_subject" => "Not applicable",
             "teaching_stage" => "I'm thinking about teaching and want to find out more",
             "subject_first_choice" => "Architecture",
             "subject_second_choice" => "Mathematics",
             "school_name" => 'Test school',
             "created_at" => current_time,
             "updated_at" => current_time
          }
        }
    end
  end
end
