FactoryBot.define do
  factory :registration_session, class: 'Candidates::Registrations::RegistrationSession' do
    transient do
      current_time { DateTime.current }
      urn { 11_048 }
      uuid { 'some-uuid' }

      placement_date do
        school = Bookings::School.find_by(urn: urn) || create(:bookings_school, urn: urn)
        create :bookings_placement_date, bookings_school: school
      end

      with do
        %i[
          subject_and_date_information
          personal_information
          contact_information
          education
          teaching_preference
          placement_preference
          availability_preference
          background_check
        ]
      end

      candidates_registrations_personal_information do
        {
          "first_name" => 'Testy',
          "last_name" => 'McTest',
          "email" => 'test@example.com',
          "created_at" => current_time,
          "updated_at" => current_time
        }
      end

      candidates_registrations_contact_information do
        {
          "building" => "Test building",
          "street" => "Test street",
          "town_or_city" => "Test town",
          "county" => "Testshire",
          "postcode" => "TE57 1NG",
          "phone" => "01234567890",
          "created_at" => current_time,
          "updated_at" => current_time
        }
      end

      candidates_registrations_background_check do
        {
          "has_dbs_check" => true,
          "created_at" => current_time,
          "updated_at" => current_time
        }
      end

      candidates_registrations_placement_preference do
        {
          "urn" => urn,
          "objectives" => "test the software",
          "created_at" => current_time,
          "updated_at" => current_time
        }
      end

      candidates_registrations_availability_preference do
        {
          "urn" => urn,
          "availability" => "Every third Tuesday",
          "created_at" => current_time,
          "updated_at" => current_time
        }
      end

      candidates_registrations_education do
        FactoryBot.attributes_for(:education).stringify_keys.merge(
          'created_at' => current_time,
          'updated_at' => current_time
        )
      end

      candidates_registrations_teaching_preference do
        FactoryBot.attributes_for(:teaching_preference).stringify_keys.merge(
          'created_at' => current_time,
          'updated_at' => current_time
        )
      end

      candidates_registrations_subject_and_date_information do
        FactoryBot.attributes_for(:subject_and_date_information, bookings_placement_date_id: placement_date.id).stringify_keys.merge(
          'created_at' => current_time,
          'updated_at' => current_time
        )
      end
    end

    initialize_with do
      new \
        with
          .map { |step| "candidates_registrations_#{step}" }
          .reduce("uuid" => uuid, "urn" => urn) { |options, step| options.merge step => send(step) }
    end

    trait :with_placement_date do
      initialize_with do
        new \
          "uuid" => uuid,
          "urn" => urn,
          "candidates_registrations_personal_information" => candidates_registrations_personal_information,
          "candidates_registrations_contact_information" => candidates_registrations_contact_information,
          "candidates_registrations_background_check" => candidates_registrations_background_check,
          "candidates_registrations_education" => candidates_registrations_education,
          "candidates_registrations_teaching_preference" => candidates_registrations_teaching_preference,
          "candidates_registrations_placement_preference" => candidates_registrations_placement_preference,
          "candidates_registrations_availability_preference" => {},
          "candidates_registrations_subject_and_date_information" => candidates_registrations_subject_and_date_information
      end
    end

    trait :with_flexible_dates do
      initialize_with do
        new \
          "uuid" => uuid,
          "urn" => urn,
          "candidates_registrations_personal_information" => candidates_registrations_personal_information,
          "candidates_registrations_contact_information" => candidates_registrations_contact_information,
          "candidates_registrations_background_check" => candidates_registrations_background_check,
          "candidates_registrations_education" => candidates_registrations_education,
          "candidates_registrations_teaching_preference" => candidates_registrations_teaching_preference,
          "candidates_registrations_placement_preference" => candidates_registrations_placement_preference,
          "candidates_registrations_availability_preference" => candidates_registrations_availability_preference,
          "candidates_registrations_subject_and_date_information" => {}
      end
    end

    trait :with_education do
      initialize_with do
        new \
          "uuid" => uuid,
          "urn" => urn,
          "candidates_registrations_personal_information" => candidates_registrations_personal_information,
          "candidates_registrations_contact_information" => candidates_registrations_contact_information,
          "candidates_registrations_background_check" => candidates_registrations_background_check,
          "candidates_registrations_education" => candidates_registrations_education,
          "candidates_registrations_placement_preference" => candidates_registrations_placement_preference
      end
    end

    # TODO: refactor this to avoid duplication building up the session
    trait :with_teaching_preference do
      initialize_with do
        new \
          "uuid" => uuid,
          "urn" => urn,
          "candidates_registrations_personal_information" => candidates_registrations_personal_information,
          "candidates_registrations_contact_information" => candidates_registrations_contact_information,
          "candidates_registrations_background_check" => candidates_registrations_background_check,
          "candidates_registrations_teaching_preference" => candidates_registrations_teaching_preference,
          "candidates_registrations_placement_preference" => candidates_registrations_placement_preference
      end
    end

    trait :with_school do
      after :build do |reg|
        school = Bookings::School.find_by(urn: reg.urn) || FactoryBot.create(:bookings_school, urn: reg.urn)

        if school.availability_preference_fixed?
          reg.save FactoryBot.build :placement_preference, urn: school.urn
        end
      end
    end
  end
end
