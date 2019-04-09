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
  end
end
