module Schools
  class SchoolProfile < ApplicationRecord
    validates :urn, presence: true, uniqueness: true

    composed_of \
      :candidate_requirement,
      class_name: 'Schools::OnBoarding::CandidateRequirement',
      mapping: [
        %w(candidate_requirement_dbs_requirement dbs_requirement),
        %w(candidate_requirement_dbs_policy dbs_policy),
        %w(candidate_requirement_requirements requirements),
        %w(candidate_requirement_requirements_details requirements_details)
      ],
      constructor: :compose

    composed_of \
      :fees,
      class_name: 'Schools::OnBoarding::Fees',
      mapping: [
        %w(fees_administration_fees administration_fees),
        %w(fees_dbs_fees dbs_fees),
        %w(fees_other_fees other_fees)
      ],
      constructor: :compose

    composed_of \
      :administration_fee,
      class_name: 'Schools::OnBoarding::AdministrationFee',
      mapping: [
        %w(administration_fee_amount_pounds amount_pounds),
        %w(administration_fee_description description),
        %w(administration_fee_interval interval),
        %w(administration_fee_payment_method payment_method),
      ],
      constructor: :compose

    composed_of \
      :dbs_fee,
      class_name: 'Schools::OnBoarding::DBSFee',
      mapping: [
        %w(dbs_fee_amount_pounds amount_pounds),
        %w(dbs_fee_description description),
        %w(dbs_fee_interval interval),
        %w(dbs_fee_payment_method payment_method),
      ],
      constructor: :compose

    composed_of \
      :other_fee,
      class_name: 'Schools::OnBoarding::OtherFee',
      mapping: [
        %w(other_fee_amount_pounds amount_pounds),
        %w(other_fee_description description),
        %w(other_fee_interval interval),
        %w(other_fee_payment_method payment_method),
      ],
      constructor: :compose

    composed_of \
      :phases_list,
      class_name: 'Schools::OnBoarding::PhasesList',
      mapping: [
        %w(phases_list_primary primary),
        %w(phases_list_secondary secondary),
        %w(phases_list_college college)
      ],
      constructor: :compose
  end
end
