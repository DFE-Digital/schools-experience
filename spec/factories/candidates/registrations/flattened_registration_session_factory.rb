FactoryBot.define do
  factory :flattened_registration_session, class: Candidates::Registrations::RegistrationSession do
    transient do
      current_time { DateTime.current }
      urn { 11048 }
      placement_date { create(:bookings_placement_date) }
      uuid { 'some-uuid' }

      with do
        %i(
          personal_information
          contact_information
          background_check
          placement_preference
          education
          teaching_preference
        )
      end

      personal_information do
        {
          "first_name"                      => 'Testy',
          "last_name"                       => 'McTest',
          "email"                           => 'test@example.com',
          "date_of_birth"                   => "2000-01-01",
          "personal_information_created_at" => current_time,
          "personal_information_updated_at" => current_time
        }
      end

      contact_information do
        {
          "building"                       => "Test building",
          "street"                         => "Test street",
          "town_or_city"                   => "Test town",
          "county"                         => "Testshire",
          "postcode"                       => "TE57 1NG",
          "phone"                          => "01234567890",
          "contact_information_created_at" => current_time,
          "contact_information_updated_at" => current_time
        }
      end

      background_check do
        {
          "has_dbs_check"               => true,
          "background_check_created_at" => current_time,
          "background_check_updated_at" => current_time
        }
      end

      placement_preference do
        {
          "urn"                             => urn,
          "availability"                    => "Every third Tuesday",
          "objectives"                      => "test the software",
          "placement_preference_created_at" => current_time,
          "placement_preference_updated_at" => current_time
        }
      end

      placement_preference_with_placement_date do
        {
          "urn"                             => urn,
          "availability"                    => nil,
          "objectives"                      => "test the software",
          "bookings_placement_date_id"      => placement_date.id,
          "placement_preference_created_at" => current_time,
          "placement_preference_updated_at" => current_time
        }
      end

      education do
        FactoryBot.attributes_for(:education).stringify_keys.merge(
          'education_created_at' => current_time,
          'education_updated_at' => current_time
        )
      end

      teaching_preference do
        FactoryBot.attributes_for(:teaching_preference).stringify_keys.merge(
          'teaching_preference_created_at' => current_time,
          'teaching_preference_updated_at' => current_time
        )
      end
    end

    initialize_with do
      new \
        with
          .reduce("uuid" => uuid, "urn" => urn) { |options, step| options.merge(send(step)) }
    end

    trait :with_placement_date do
      initialize_with do
        new \
          with
            .tap { |steps| steps.delete :placement_preference }
            .tap { |steps| steps << :placement_preference_with_placement_date }
            .reduce("uuid" => uuid, "urn" => urn) { |options, step| options.merge(send(step)) }
      end
    end

    trait :with_education do
      initialize_with do
        new \
          %i(
            personal_information
            contact_information
            background_check
            education
            placement_preference
          ).reduce("uuid" => uuid, "urn" => urn) { |options, step| options.merge(send(step)) }
      end
    end

    trait :with_teaching_preference do
      initialize_with do
        new \
          %i(
            personal_information
            contact_information
            background_check
            teaching_preference
            placement_preference
        ).reduce("uuid" => uuid, "urn" => urn) { |options, step| options.merge(send(step)) }
      end
    end

    trait :with_school do
      after :build do |reg|
        Bookings::School.find_by(urn: reg.urn) || FactoryBot.create(:bookings_school, urn: reg.urn)
      end
    end
  end
end
