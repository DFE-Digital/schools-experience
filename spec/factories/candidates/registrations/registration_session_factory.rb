FactoryBot.define do
  factory :registration_session, class: Candidates::Registrations::RegistrationSession do
    transient do
      current_time { DateTime.current }
      urn { 11048 }
      placement_date { create(:bookings_placement_date) }

      candidates_registrations_contact_information do
        {
          "full_name"    => 'Testy McTest',
          "email"        => 'test@example.com',
          "building"     => "Test building",
          "street"       => "Test street",
          "town_or_city" => "Test town",
          "county"       => "Testshire",
          "postcode"     => "TE57 1NG",
          "phone"        => "01234567890",
          "created_at"   => current_time,
          "updated_at"   => current_time
        }
      end

      candidates_registrations_background_check do
        {
          "has_dbs_check" => true,
          "created_at"    => current_time,
          "updated_at"    => current_time
        }
      end

      candidates_registrations_placement_preference do
        {
          "urn"          => urn,
          "availability" => "Every third Tuesday",
          "objectives"   => "test the software",
          "created_at"   => current_time,
          "updated_at"   => current_time
        }
      end

      candidates_registrations_subject_preference do
        {
          "degree_stage"              => "I don't have a degree and am not studying for one",
          "degree_stage_explaination" => "",
          "degree_subject"            => "Not applicable",
          "teaching_stage"            => "I’m very sure and think I’ll apply",
          "subject_first_choice"      => "Maths",
          "subject_second_choice"     => "Physics",
          "urn"                       => urn,
          "created_at"                => current_time,
          "updated_at"                => current_time
        }
      end
    end

    initialize_with do
      new \
        "candidates_registrations_contact_information"  => candidates_registrations_contact_information,
        "candidates_registrations_background_check"     => candidates_registrations_background_check,
        "candidates_registrations_placement_preference" => candidates_registrations_placement_preference,
        "candidates_registrations_subject_preference"   => candidates_registrations_subject_preference
    end

    trait :with_placement_date do
      initialize_with do
        new \
          "candidates_registrations_contact_information"  => candidates_registrations_contact_information,
          "candidates_registrations_background_check"     => candidates_registrations_background_check,
          "candidates_registrations_subject_preference"   => candidates_registrations_subject_preference,
          "candidates_registrations_placement_preference" => candidates_registrations_placement_preference
            .merge(
              "availability" => nil,
              "bookings_placement_date_id" => placement_date.id
            )
      end
    end
  end
end
