FactoryBot.define do
  factory :school_profile, class: 'Schools::SchoolProfile' do
    urn { 1234567890 }

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
  end
end
