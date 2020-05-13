module Schools
  class SchoolProfile < ApplicationRecord
    self.ignored_columns = %w[show_candidate_requirements_selection]

    delegate :urn, to: :bookings_school

    validates :bookings_school, presence: true

    before_validation do
      # Some steps in the wizard depend on previous steps and don't make
      # sense if the profile is edited to uncheck the options that require
      # these steps. If this is the case we want to reset those steps to their
      # initial state.
      unless fees.administration_fees?
        self.administration_fee = OnBoarding::AdministrationFee.new
      end
      unless fees.dbs_fees?
        self.dbs_fee = OnBoarding::DBSFee.new
      end
      unless fees.other_fees?
        self.other_fee = OnBoarding::OtherFee.new
      end
      unless phases_list.primary?
        self.key_stage_list = OnBoarding::KeyStageList.new
      end
      unless requires_subjects?
        subjects.destroy_all
      end
      unless candidate_requirements_choice.has_requirements
        self.candidate_requirements_selection = OnBoarding::CandidateRequirementsSelection.new
      end
      unless access_needs_support.supports_access_needs?
        self.access_needs_detail = OnBoarding::AccessNeedsDetail.new
        self.disability_confident = OnBoarding::DisabilityConfident.new
        self.access_needs_policy = OnBoarding::AccessNeedsPolicy.new
      end
    end

    validate :administration_fee_not_set, unless: -> { fees.administration_fees? }
    validate :dbs_fee_not_set, unless: -> { fees.dbs_fees? }
    validate :other_fee_not_set, unless: -> { fees.other_fees? }
    validate :key_stage_list_not_set, unless: -> { phases_list.primary? }
    validates :subjects, absence: true, unless: :requires_subjects?

    DEPENDENT_STAGES = [
      [:administration_fee, 'fees.administration_fees'],
      [:dbs_fee, 'fees.dbs_fees'],
      [:other_fee, 'fees.other_fees'],
      [:key_stage_list, 'phases_list.primary']
    ].freeze

    DEPENDENT_STAGES.each do |attr, dependency|
      define_method "#{attr}_not_set" do
        unless send(attr) == send(attr).class.new
          errors.add :base, "#{attr} should not be set when `#{dependency} == false`"
        end
      end
    end

    composed_of \
      :dbs_requirement,
      class_name: 'Schools::OnBoarding::DbsRequirement',
      mapping: [
        %w[dbs_requirement_requires_check requires_check],
        %w[dbs_requirement_dbs_policy_details dbs_policy_details],
        %w[dbs_requirement_no_dbs_policy_details no_dbs_policy_details]
      ],
      constructor: :compose

    composed_of \
      :candidate_requirements_choice,
      class_name: 'Schools::OnBoarding::CandidateRequirementsChoice',
      mapping: [
        %w[candidate_requirements_choice_has_requirements has_requirements]
      ],
      constructor: :compose

    composed_of \
      :candidate_requirements_selection,
      class_name: 'Schools::OnBoarding::CandidateRequirementsSelection',
      mapping: [
        %w[candidate_requirements_selection_on_teacher_training_course on_teacher_training_course],
        %w[candidate_requirements_selection_not_on_another_training_course not_on_another_training_course],
        %w[candidate_requirements_selection_has_or_working_towards_degree has_or_working_towards_degree],
        %w[candidate_requirements_selection_live_locally live_locally],
        %w[candidate_requirements_selection_maximum_distance_from_school maximum_distance_from_school],
        %w[candidate_requirements_selection_provide_photo_identification provide_photo_identification],
        %w[candidate_requirements_selection_photo_identification_details photo_identification_details],
        %w[candidate_requirements_selection_other other],
        %w[candidate_requirements_selection_other_details other_details]
      ],
      constructor: :compose

    composed_of \
      :fees,
      class_name: 'Schools::OnBoarding::Fees',
      mapping: [
        %w[fees_administration_fees administration_fees],
        %w[fees_dbs_fees dbs_fees],
        %w[fees_other_fees other_fees]
      ],
      constructor: :compose

    composed_of \
      :administration_fee,
      class_name: 'Schools::OnBoarding::AdministrationFee',
      mapping: [
        %w[administration_fee_amount_pounds amount_pounds],
        %w[administration_fee_description description],
        %w[administration_fee_interval interval],
        %w[administration_fee_payment_method payment_method]
      ],
      constructor: :compose

    composed_of \
      :dbs_fee,
      class_name: 'Schools::OnBoarding::DBSFee',
      mapping: [
        %w[dbs_fee_amount_pounds amount_pounds],
        %w[dbs_fee_description description],
        %w[dbs_fee_interval interval],
        %w[dbs_fee_payment_method payment_method]
      ],
      constructor: :compose

    composed_of \
      :other_fee,
      class_name: 'Schools::OnBoarding::OtherFee',
      mapping: [
        %w[other_fee_amount_pounds amount_pounds],
        %w[other_fee_description description],
        %w[other_fee_interval interval],
        %w[other_fee_payment_method payment_method]
      ],
      constructor: :compose

    composed_of \
      :phases_list,
      class_name: 'Schools::OnBoarding::PhasesList',
      mapping: [
        %w[phases_list_primary primary],
        %w[phases_list_secondary secondary],
        %w[phases_list_college college],
        %w[phases_list_secondary_and_college secondary_and_college]
      ],
      constructor: :compose

    composed_of \
      :key_stage_list,
      class_name: 'Schools::OnBoarding::KeyStageList',
      mapping: [
        %w[key_stage_list_early_years early_years],
        %w[key_stage_list_key_stage_1 key_stage_1],
        %w[key_stage_list_key_stage_2 key_stage_2]
      ],
      constructor: :compose

    composed_of \
      :description,
      class_name: 'Schools::OnBoarding::Description',
      mapping: [
        %w[description_details details]
      ],
      constructor: :compose

    composed_of \
      :candidate_experience_detail,
      class_name: 'Schools::OnBoarding::CandidateExperienceDetail',
      mapping: [
        %w[candidate_experience_detail_business_dress business_dress],
        %w[candidate_experience_detail_cover_up_tattoos cover_up_tattoos],
        %w[candidate_experience_detail_remove_piercings remove_piercings],
        %w[candidate_experience_detail_smart_casual smart_casual],
        %w[candidate_experience_detail_other_dress_requirements other_dress_requirements],
        %w[candidate_experience_detail_other_dress_requirements_detail other_dress_requirements_detail],
        %w[candidate_experience_detail_parking_provided parking_provided],
        %w[candidate_experience_detail_parking_details parking_details],
        %w[candidate_experience_detail_nearby_parking_details nearby_parking_details],
        %w[candidate_experience_detail_start_time start_time],
        %w[candidate_experience_detail_end_time end_time],
        %w[candidate_experience_detail_times_flexible times_flexible],
        %w[candidate_experience_detail_times_flexible_details times_flexible_details]
      ],
      constructor: :compose

    composed_of \
      :access_needs_support,
      class_name: 'Schools::OnBoarding::AccessNeedsSupport',
      mapping: [
        %w[access_needs_support_supports_access_needs supports_access_needs]
      ],
      constructor: :compose

    composed_of \
      :access_needs_detail,
      class_name: 'Schools::OnBoarding::AccessNeedsDetail',
      mapping: [
        %w[access_needs_detail_description description]
      ],
      constructor: :compose

    composed_of \
      :disability_confident,
      class_name: 'Schools::OnBoarding::DisabilityConfident',
      mapping: [
        %w[disability_confident_is_disability_confident is_disability_confident]
      ],
      constructor: :compose

    composed_of \
      :access_needs_policy,
      class_name: 'Schools::OnBoarding::AccessNeedsPolicy',
      mapping: [
        %w[access_needs_policy_has_access_needs_policy has_access_needs_policy],
        %w[access_needs_policy_url url]
      ],
      constructor: :compose

    composed_of \
      :experience_outline,
      class_name: 'Schools::OnBoarding::ExperienceOutline',
      mapping: [
        %w[experience_outline_candidate_experience candidate_experience],
        %w[experience_outline_provides_teacher_training provides_teacher_training],
        %w[experience_outline_teacher_training_details teacher_training_details],
        %w[experience_outline_teacher_training_url teacher_training_url]
      ],
      constructor: :compose

    composed_of \
      :admin_contact,
      class_name: 'Schools::OnBoarding::AdminContact',
      mapping: [
        %w[admin_contact_email email],
        %w[admin_contact_email_secondary email_secondary],
        %w[admin_contact_phone phone]
      ],
      constructor: :compose

    composed_of \
      :confirmation,
      class_name: 'Schools::OnBoarding::Confirmation',
      mapping: [
        %w[confirmation_acceptance acceptance]
      ],
      constructor: :compose

    has_many :profile_subjects,
      class_name: 'Schools::OnBoarding::ProfileSubject',
      foreign_key: :schools_school_profile_id,
      inverse_of: :school_profile,
      dependent: :destroy

    has_many :subjects,
      class_name: 'Bookings::Subject',
      source: :subject,
      through: :profile_subjects,
      dependent: :destroy

    belongs_to :bookings_school,
      class_name: 'Bookings::School',
      inverse_of: :school_profile,
      foreign_key: 'bookings_school_id'

    def available_subjects
      Bookings::Subject.all
    end

    def current_step
      OnBoarding::CurrentStep.for self
    end

    def completed?
      current_step == :COMPLETED
    end

    def requires_subjects?
      phases_list.secondary? || phases_list.college?
    end
  end
end
