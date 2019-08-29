FactoryBot.define do
  factory :school_profile, class: 'Schools::SchoolProfile' do
    before(:create) do |sp|
      sp.bookings_school = Bookings::School.find_by(urn: 123456) || create(:bookings_school, urn: 123456)
    end

    trait :with_dbs_requirement do
      after :build do |profile|
        profile.dbs_requirement = FactoryBot.build :dbs_requirement
      end
    end

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

    trait :with_subjects do
      after :create do |profile|
        profile.subjects << FactoryBot.create(:bookings_subject)
      end
    end

    trait :with_description do
      after :build do |profile|
        profile.description = FactoryBot.build :description
      end
    end

    transient do
      parking { true }
      disabled_facilities { false }
      times_flexible { true }
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

        if evaluator.times_flexible == false
          traits << :without_flexible_times
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

    trait :completed do
      with_dbs_requirement
      with_candidate_requirement
      with_fees
      with_administration_fee
      with_dbs_fee
      with_other_fee
      with_only_early_years_phase
      with_phases
      with_key_stage_list
      with_subjects
      with_description
      with_candidate_experience_detail
      with_experience_outline
      with_admin_contact
    end
  end
end
