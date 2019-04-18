FactoryBot.define do
  factory :school_profile, class: 'Schools::SchoolProfile' do
    urn { 123456 }

    trait :with_candidate_requirement do
      candidate_requirement_dbs_requirement { 'sometimes' }
      candidate_requirement_dbs_policy { 'Super secure' }
      candidate_requirement_requirements { true }
      candidate_requirement_requirements_details { 'Gotta go fast' }
    end

    trait :with_fees do
      fees_administration_fees { true }
      fees_dbs_fees { true }
      fees_other_fees { true }
    end

    trait :with_administration_fee do
      administration_fee_amount_pounds { 123.45 }
      administration_fee_description { 'General administration' }
      administration_fee_interval { 'Daily' }
      administration_fee_payment_method { 'Travelers Cheques' }
    end

    trait :with_dbs_fee do
      dbs_fee_amount_pounds { 200 }
      dbs_fee_description { 'DBS check' }
      dbs_fee_interval { 'One-off' }
      dbs_fee_payment_method { 'Ethereum' }
    end

    trait :with_other_fee do
      other_fee_amount_pounds { 444.44 }
      other_fee_description { 'Owl repellent / other protective gear' }
      other_fee_interval { 'One-off' }
      other_fee_payment_method { 'Stamps' }
    end

    trait :with_phases do
      phases_list_primary { true }
      phases_list_secondary { true }
      phases_list_college { true }
    end

    trait :with_only_early_years_phase do
      phases_list_primary { true }
      phases_list_secondary { false }
      phases_list_college { false }
    end

    trait :with_key_stage_list do
      key_stage_list_early_years { true }
      key_stage_list_key_stage_1 { true }
      key_stage_list_key_stage_2 { true }
    end

    trait :with_secondary_subjects do
      after :create do |profile|
        profile.secondary_subjects << FactoryBot.create(:bookings_subject)
      end
    end

    trait :with_college_subjects do
      after :create do |profile|
        profile.college_subjects << FactoryBot.create(:bookings_subject)
      end
    end

    trait :with_specialism do
      specialism_has_specialism { true }
      specialism_details { 'Falconry' }
    end

    transient do
      parking { true }
      disabled_facilities { false }
    end

    trait :with_candidate_experience_detail do
      after :build do |profile, evaluator|
        traits = []

        if evaluator.parking == false
          traits << :without_parking
        end

        if evaluator.disabled_facilities
          traits << :with_disabled_facilities
        end

        profile.candidate_experience_detail = FactoryBot.build :candidate_experience_detail, *traits
      end
    end

    trait :with_experience_outline do
      after :build do |profile|
        profile.experience_outline = FactoryBot.build :experience_outline
      end
    end

    trait :with_admin_contact do
      after :build do |profile|
        profile.admin_contact = FactoryBot.build :admin_contact
      end
    end

    trait :with_availability_description do
      after :build do |profile|
        profile.availability_description = FactoryBot.build :availability_description
      end
    end

    trait :completed do
      with_candidate_requirement
      with_fees
      with_administration_fee
      with_dbs_fee
      with_other_fee
      with_only_early_years_phase
      with_key_stage_list
      with_secondary_subjects
      with_college_subjects
      with_specialism
      with_candidate_experience_detail
      with_availability_description
      with_experience_outline
      with_admin_contact
    end
  end
end
