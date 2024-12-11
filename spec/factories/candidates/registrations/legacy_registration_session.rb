# TODO: SE-1877 remove this file
FactoryBot.define do
  factory :legacy_registration_session, class: 'Candidates::Registrations::RegistrationSession' do
    transient do
      urn { 11_048 }
      bookings_placement_date_id { 16 }
      timestamp { Time.zone.today }
    end

    initialize_with do
      new \
        "uuid" => "some-uuid",
        "urn" => urn,
        "candidates_registrations_personal_information" => {
          "first_name" => "Testy",
          "last_name" => "McTest",
          "email" => "test@example.com",
          "created_at" => timestamp,
          "updated_at" => timestamp
        },
        "candidates_registrations_contact_information" => {
          "building" => "Test building",
          "street" => "Test street",
          "town_or_city" => "Test town",
          "county" => "Testshire",
          "postcode" => "TE57 1NG",
          "phone" => "01234567890",
          "created_at" => timestamp,
          "updated_at" => timestamp
        },
        "candidates_registrations_background_check" => {
          "has_dbs_check" => true,
          "created_at" => timestamp,
          "updated_at" => timestamp
        },
        "candidates_registrations_education" => {
          "degree_stage" => "Other",
          "degree_stage_explaination" => "Khan academy, level 3",
          "degree_subject" => "Biological sciences",
          "created_at" => timestamp,
          "updated_at" => timestamp
        },
        "candidates_registrations_teaching_preference" => {
          "teaching_stage" => "I’m very sure and think I’ll apply",
          "subject_first_choice" => "Astronomy",
          "subject_second_choice" => "History",
          "created_at" => timestamp,
          "updated_at" => timestamp
        },
        "candidates_registrations_placement_preference" => {
          "urn" => urn,
          "objectives" => "test the software",
          "created_at" => timestamp,
          "updated_at" => timestamp,
          "bookings_placement_date_id" => bookings_placement_date_id
        }
    end
  end
end
