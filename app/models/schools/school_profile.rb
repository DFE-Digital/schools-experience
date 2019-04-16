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

    composed_of \
      :key_stage_list,
      class_name: 'Schools::OnBoarding::KeyStageList',
      mapping: [
        %w(key_stage_list_early_years early_years),
        %w(key_stage_list_key_stage_1 key_stage_1),
        %w(key_stage_list_key_stage_2 key_stage_2)
      ],
      constructor: :compose

    composed_of \
      :specialism,
      class_name: 'Schools::OnBoarding::Specialism',
      mapping: [
        %w(specialism_has_specialism has_specialism),
        %w(specialism_details details)
      ],
      constructor: :compose

    composed_of \
      :candidate_experience_detail,
      class_name: 'Schools::OnBoarding::CandidateExperienceDetail',
      mapping: [
        %w(candidate_experience_detail_business_dress business_dress),
        %w(candidate_experience_detail_cover_up_tattoos cover_up_tattoos),
        %w(candidate_experience_detail_remove_piercings remove_piercings),
        %w(candidate_experience_detail_smart_casual smart_casual),
        %w(candidate_experience_detail_other_dress_requirements other_dress_requirements),
        %w(candidate_experience_detail_other_dress_requirements_detail other_dress_requirements_detail),
        %w(candidate_experience_detail_parking_provided parking_provided),
        %w(candidate_experience_detail_parking_details parking_details),
        %w(candidate_experience_detail_nearby_parking_details nearby_parking_details),
        %w(candidate_experience_detail_disabled_facilities disabled_facilities),
        %w(candidate_experience_detail_disabled_facilities_details disabled_facilities_details),
        %w(candidate_experience_detail_start_time start_time),
        %w(candidate_experience_detail_end_time end_time),
        %w(candidate_experience_detail_times_flexible times_flexible)
      ],
      constructor: :compose

    has_many :secondary_phase_subjects,
      -> { at_phase Bookings::Phase.secondary },
      class_name: 'Schools::OnBoarding::PhaseSubject',
      foreign_key: :schools_school_profile_id,
      dependent: :destroy

    has_many :college_phase_subjects,
      -> { at_phase Bookings::Phase.college },
      class_name: 'Schools::OnBoarding::PhaseSubject',
      foreign_key: :schools_school_profile_id,
      dependent: :destroy

    has_many :secondary_subjects,
      class_name: 'Bookings::Subject',
      source: :subject,
      through: :secondary_phase_subjects,
      dependent: :destroy

    has_many :college_subjects,
      class_name: 'Bookings::Subject',
      source: :subject,
      through: :college_phase_subjects,
      dependent: :destroy

    has_many :placement_dates,
      class_name: 'Bookings::PlacementDate',
      foreign_key: :schools_school_profile_id

    def available_secondary_subjects
      Bookings::Subject.all
    end

    def available_college_subjects
      Bookings::Subject.all
    end
  end
end
