FactoryBot.define do
  factory :bookings_school, class: Bookings::School do
    sequence(:name) { |n| "school #{n}" }
    coordinates { Bookings::School::GEOFACTORY.point(-2.241, 53.481) }
    fee { 0 }
    sequence(:urn) { |n| 10000 + n }
    sequence(:address_1) { |n| "#{n} Something Street" }
    sequence(:postcode) { |n| "M#{n} 2JF" }
    association :school_type, factory: :bookings_school_type
    sequence(:contact_email) { |n| "admin#{n}@school.org" }
    availability_info { 'We can offer placements throughout June and July for the remainder of this academic year (up to the 21st July).' }
    availability_preference_fixed { false }

    trait :disabled do
      enabled { false }
    end

    trait :full_address do
      sequence(:address_2) { |n| "#{n} Something area" }
      sequence(:address_3) { |n| "#{n} Something area" }
      sequence(:town) { |n| "#{n} Something town" }
      sequence(:county) { |n| "#{n} Something county" }
    end

    trait :with_fixed_availability_preference do
      availability_preference_fixed { true }
    end

    trait :with_placement_info do
      placement_info { 'Our free Taster Day will allow you to observe some lessons (subjects may vary), have a tour of the school, speak to students, staff and current trainee teachers' }
    end

    trait :with_primary_key_stage_info do
      primary_key_stage_info { 'Early years foundation stage (EYFS), Key stage 1, Key stage 2' }
    end

    transient do
      subject_count { 1 }
    end

    trait :with_subjects do
      after :create do |school, evaluator|
        evaluator.subject_count.times do
          school.subjects << FactoryBot.create(:bookings_subject)
        end
      end
    end

    trait :with_placement_dates do
      after :create do |school|
        FactoryBot.create(:bookings_placement_date, bookings_school: school)
      end
    end

    trait :with_teacher_training_info do
      teacher_training_info { 'We offer a PGCE in partnership with Chester University. We are a lead school for School Direct' }
    end

    trait :with_teacher_training_website do
      teacher_training_website { 'http://teacher-training.example.com' }
    end

    trait :early_years do
      after(:create) do |school, _evaluator|
        school.phases << Bookings::Phase.find_by!(edubase_id: 1)
      end
    end

    trait :primary do
      after(:create) do |school, _evaluator|
        school.phases << Bookings::Phase.find_by!(edubase_id: 2)
      end
    end

    trait :secondary do
      after(:create) do |school, _evaluator|
        school.phases << Bookings::Phase.find_by!(edubase_id: 4)
      end
    end

    trait :college do
      after(:create) do |school, _evaluator|
        school.phases << Bookings::Phase.find_by!(edubase_id: 6)
      end
    end

    trait :with_profile do
      association :profile, factory: :bookings_profile
    end
  end
end
