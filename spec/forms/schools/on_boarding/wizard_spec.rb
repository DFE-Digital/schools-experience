require "rails_helper"

describe Schools::OnBoarding::Wizard do
  let(:school_profile) { build(:school_profile) }
  let(:instance) { described_class.new(school_profile) }

  describe "#next_step" do
    subject(:next_step) { instance.next_step(previous_step) }

    context "when previous_step is nil" do
      let(:previous_step) { nil }

      it "returns the first required step (from all steps/sections)" do
        is_expected.to be(:phases_list)
      end
    end

    context "when previous_step is unknown" do
      let(:previous_step) { :unknown }

      it "returns the first required step (from all steps/sections)" do
        is_expected.to be(:phases_list)
      end
    end

    context "when previous_step is the last step of a section" do
      let(:previous_step) { :other_fee }

      it { is_expected.to be_nil }
    end

    context "when the step after previous_step is not yet completed" do
      let(:previous_step) { :dbs_requirement }

      it "returns the next step" do
        is_expected.to be(:fees)
      end
    end

    context "when the step after previous_step is already completed" do
      let(:school_profile) { build(:school_profile, :with_fees) }
      let(:previous_step) { :dbs_requirement }

      it "skips the complted step, returning the next incomplete step" do
        is_expected.to be(:administration_fee)
      end
    end

    describe "section/step specific behaviour" do
      context "within the safeguarding_and_fees section" do
        context "when the next step is fees" do
          let(:previous_step) { :dbs_requirement }

          it { is_expected.to be(:fees) }

          context "when the fees step has already been completed" do
            let(:school_profile) { build(:school_profile, :with_fees) }

            it { is_expected.to be(:administration_fee) }
          end
        end

        context "when the next step is administration_fee" do
          let(:school_profile) { build(:school_profile, :with_fees) }
          let(:previous_step) { :fees }

          it { is_expected.to be(:administration_fee) }

          context "when the administration_fee step has already been completed" do
            let(:school_profile) { build(:school_profile, :with_fees, :with_administration_fee) }

            it { is_expected.to be(:dbs_fee) }
          end

          context "when the administration_fee step is not applicable" do
            let(:school_profile) { build(:school_profile, fees_dbs_fees: true) }

            it { is_expected.to be(:dbs_fee) }
          end
        end

        context "when the next step is dbs_fee" do
          let(:school_profile) { build(:school_profile, :with_fees) }
          let(:previous_step) { :administration_fee }

          it { is_expected.to be(:dbs_fee) }

          context "when the dbs_fee step has already been completed" do
            let(:school_profile) { build(:school_profile, :with_fees, :with_dbs_fee) }

            it { is_expected.to be(:other_fee) }
          end

          context "when the dbs_fee step is not applicable" do
            let(:school_profile) { build(:school_profile, fees_other_fees: true) }

            it { is_expected.to be(:other_fee) }
          end
        end

        context "when the next step is other_fee" do
          let(:school_profile) { build(:school_profile, :with_fees) }
          let(:previous_step) { :dbs_fee }

          it { is_expected.to be(:other_fee) }

          context "when the other_fee step has already been completed" do
            let(:school_profile) { build(:school_profile, :with_fees, :with_other_fee) }

            it { is_expected.to be_nil }
          end

          context "when the other_fee step is not applicable" do
            let(:school_profile) { build(:school_profile) }

            it { is_expected.to be_nil }
          end
        end
      end

      context "within the subjects_and_education_phases section" do
        context "when the next step is key_stage_list" do
          let(:school_profile) { build(:school_profile, phases_list_primary: true) }
          let(:previous_step) { :phases_list }

          it { is_expected.to be(:key_stage_list) }

          context "when the key_stage_list step has already been completed" do
            let(:school_profile) { build(:school_profile, :with_key_stage_list, phases_list_primary: true) }

            it { is_expected.to be_nil }
          end

          context "when the key_stage_list step is not applicable" do
            let(:school_profile) { build(:school_profile, phases_list_primary: false) }

            it { is_expected.to be_nil }
          end
        end

        context "when the next step is subjects" do
          let(:school_profile) { build(:school_profile, phases_list_college: true) }
          let(:previous_step) { :key_stage_list }

          it { is_expected.to be(:subjects) }

          context "when the phase list is secondary" do
            let(:school_profile) { build(:school_profile, phases_list_secondary: true) }

            it { is_expected.to be(:subjects) }
          end

          context "when the subjects step has already been completed" do
            let(:school_profile) { build(:school_profile, :with_subjects) }

            it { is_expected.to be_nil }
          end

          context "when the subjects step is not applicable" do
            let(:school_profile) { build(:school_profile, phases_list_primary: true) }

            it { is_expected.to be_nil }
          end
        end
      end

      context "within the candidate_requirements_and_school_experience_details section" do
        context "when the next step is description" do
          let(:previous_step) { :candidate_requirements_selection }

          it { is_expected.to be(:description) }

          context "when the description step has already been completed" do
            let(:school_profile) { build(:school_profile, :with_description) }

            it { is_expected.to be(:candidate_dress_code) }
          end
        end

        context "when the next step is candiate_dress_code" do
          let(:previous_step) { :description }

          it { is_expected.to be(:candidate_dress_code) }

          context "when the candiate_dress_code step has already been completed" do
            let(:school_profile) { build(:school_profile, :with_candidate_dress_code) }

            it { is_expected.to be(:candidate_parking_information) }
          end
        end

        context "when the next step is candidate_parking_information" do
          let(:previous_step) { :candidate_dress_code }

          it { is_expected.to be(:candidate_parking_information) }

          context "when the candidate_parking_information step has already been completed" do
            let(:school_profile) { build(:school_profile, :with_candidate_parking_information) }

            it { is_expected.to be(:candidate_experience_schedule) }
          end
        end

        context "when the next step is candidate_experience_schedule" do
          let(:previous_step) { :candidate_parking_information }

          it { is_expected.to be(:candidate_experience_schedule) }

          context "when the candidate_experience_schedule step has already been completed" do
            let(:school_profile) { build(:school_profile, :with_candidate_experience_schedule) }

            it { is_expected.to be(:experience_outline) }
          end
        end

        context "when the next step is experience_outline" do
          let(:previous_step) { :candidate_experience_schedule }

          it { is_expected.to be(:experience_outline) }

          context "when the experience_outline step has already been completed" do
            let(:school_profile) { build(:school_profile, :with_experience_outline) }

            it { is_expected.to be(:teacher_training) }
          end
        end

        context "when the next step is teacher_training" do
          let(:previous_step) { :experience_outline }

          it { is_expected.to be(:teacher_training) }

          context "when the teacher_training step has already been completed" do
            let(:school_profile) { build(:school_profile, :with_teacher_training) }

            it { is_expected.to be_nil }
          end
        end
      end

      context "within the disability_and_access section" do
        context "when the next step is access_needs_detail" do
          let(:school_profile) { build(:school_profile, :with_access_needs_support) }
          let(:previous_step) { :access_needs_support }

          it { is_expected.to be(:access_needs_detail) }

          context "when the access_needs_detail step has already been completed" do
            let(:school_profile) { build(:school_profile, :with_access_needs_support, :with_access_needs_detail) }

            it { is_expected.to be(:disability_confident) }
          end

          context "when the access_needs_detail step is not applicable" do
            let(:school_profile) { build(:school_profile, :without_access_needs_support) }

            it { is_expected.to be_nil }
          end
        end

        context "when the next step is disability_confident" do
          let(:school_profile) { build(:school_profile, :with_access_needs_support) }
          let(:previous_step) { :access_needs_detail }

          it { is_expected.to be(:disability_confident) }

          context "when the disability_confident step has already been completed" do
            let(:school_profile) { build(:school_profile, :with_access_needs_support, :with_disability_confident) }

            it { is_expected.to be(:access_needs_policy) }
          end

          context "when the access_needs_detail step is not applicable" do
            let(:school_profile) { build(:school_profile, :without_access_needs_support) }

            it { is_expected.to be_nil }
          end
        end

        context "when the next step is access_needs_policy" do
          let(:school_profile) { build(:school_profile, :with_access_needs_support) }
          let(:previous_step) { :disability_confident }

          it { is_expected.to be(:access_needs_policy) }

          context "when the access_needs_policy step has already been completed" do
            let(:school_profile) { build(:school_profile, :with_access_needs_support, :with_access_needs_policy) }

            it { is_expected.to be_nil }
          end

          context "when the access_needs_policy step is not applicable" do
            let(:school_profile) { build(:school_profile, :without_access_needs_support) }

            it { is_expected.to be_nil }
          end
        end
      end
    end
  end

  describe "#step_state" do
    let(:step) { :dbs_requirement }

    subject { instance.step_state(step) }

    it { is_expected.to be(:not_started) }

    context "when the step has been completed" do
      let(:school_profile) { build(:school_profile, :with_dbs_requirement) }

      it { is_expected.to be(:complete) }
    end

    context "when the step cannot be started yet" do
      let(:step) { :other_fee }

      it { is_expected.to be(:cannot_start_yet) }
    end

    context "when the step is not applicable" do
      let(:school_profile) { build(:school_profile, :with_key_stage_list, phases_list_primary: true) }

      let(:step) { :subjects }

      it { is_expected.to be(:not_applicable) }
    end

    describe "section/step specific behaviour" do
      context "when checking the state of administration_fee" do
        let(:step) { :administration_fee }

        context "when administration_fee is applicable" do
          let(:school_profile) { build(:school_profile, :with_fees) }

          it { is_expected.to be(:not_started) }
        end

        context "when administration_fee cannot be started yet" do
          let(:school_profile) { build(:school_profile) }

          it { is_expected.to be(:cannot_start_yet) }
        end

        context "when administration_fee is not applicable" do
          let(:school_profile) { build(:school_profile, :with_dbs_requirement, :with_fees, fees_administration_fees: false) }

          it { is_expected.to be(:not_applicable) }
        end
      end

      context "when checking the state of dbs_fee" do
        let(:step) { :dbs_fee }

        context "when dbs_fee is applicable" do
          let(:school_profile) { build(:school_profile, :with_fees) }

          it { is_expected.to be(:not_started) }
        end

        context "when dbs_fee cannot be started yet" do
          let(:school_profile) { build(:school_profile) }

          it { is_expected.to be(:cannot_start_yet) }
        end

        context "when dbs_fee is not applicable" do
          let(:school_profile) { build(:school_profile, :with_dbs_requirement, :with_fees, fees_dbs_fees: false) }

          it { is_expected.to be(:not_applicable) }
        end
      end

      context "when checking the state of other_fee" do
        let(:step) { :other_fee }

        context "when other_fee is applicable" do
          let(:school_profile) { build(:school_profile, :with_fees) }

          it { is_expected.to be(:not_started) }
        end

        context "when other_fee cannot be started yet" do
          let(:school_profile) { build(:school_profile) }

          it { is_expected.to be(:cannot_start_yet) }
        end

        context "when other_fee is not applicable" do
          let(:school_profile) { build(:school_profile, :with_dbs_requirement, :with_fees, fees_other_fees: false) }

          it { is_expected.to be(:not_applicable) }
        end
      end

      context "when checking the state of key_stage_list" do
        let(:step) { :key_stage_list }

        context "when key_stage_list is applicable" do
          let(:school_profile) { build(:school_profile, :with_phases) }

          it { is_expected.to be(:not_started) }
        end

        context "when key_stage_list cannot be started yet" do
          let(:school_profile) { build(:school_profile) }

          it { is_expected.to be(:cannot_start_yet) }
        end

        context "when key_stage_list is not applicable" do
          let(:school_profile) { build(:school_profile, :with_phases, phases_list_primary: false) }

          it { is_expected.to be(:not_applicable) }
        end
      end

      context "when checking the state of subjects" do
        let(:step) { :subjects }

        context "when subjects is applicable" do
          let(:school_profile) { build(:school_profile, :with_phases, :with_key_stage_list) }

          it { is_expected.to be(:not_started) }
        end

        context "when subjects cannot be started yet" do
          let(:school_profile) { build(:school_profile) }

          it { is_expected.to be(:cannot_start_yet) }
        end

        context "when subjects is not applicable" do
          let(:school_profile) { build(:school_profile, :with_only_early_years_phase, :with_key_stage_list) }

          it { is_expected.to be(:not_applicable) }
        end
      end

      context "when checking the state of access_needs_detail" do
        let(:step) { :access_needs_detail }

        context "when access_needs_detail is applicable" do
          let(:school_profile) { build(:school_profile, :with_access_needs_support) }

          it { is_expected.to be(:not_started) }
        end

        context "when access_needs_detail cannot be started yet" do
          let(:school_profile) { build(:school_profile) }

          it { is_expected.to be(:cannot_start_yet) }
        end

        context "when access_needs_detail is not applicable" do
          let(:school_profile) { build(:school_profile, :without_access_needs_support) }

          it { is_expected.to be(:not_applicable) }
        end
      end

      context "when checking the state of disability_confident" do
        let(:step) { :disability_confident }

        context "when disability_confident is applicable" do
          let(:school_profile) { build(:school_profile, :with_access_needs_support) }

          it { is_expected.to be(:not_started) }
        end

        context "when disability_confident cannot be started yet" do
          let(:school_profile) { build(:school_profile) }

          it { is_expected.to be(:cannot_start_yet) }
        end

        context "when disability_confident is not applicable" do
          let(:school_profile) { build(:school_profile, :without_access_needs_support) }

          it { is_expected.to be(:not_applicable) }
        end
      end

      context "when checking the state of access_needs_policy" do
        let(:step) { :access_needs_policy }

        context "when access_needs_policy is applicable" do
          let(:school_profile) { build(:school_profile, :with_access_needs_support) }

          it { is_expected.to be(:not_started) }
        end

        context "when access_needs_policy cannot be started yet" do
          let(:school_profile) { build(:school_profile) }

          it { is_expected.to be(:cannot_start_yet) }
        end

        context "when access_needs_policy is not applicable" do
          let(:school_profile) { build(:school_profile, :without_access_needs_support) }

          it { is_expected.to be(:not_applicable) }
        end
      end
    end
  end

  describe "#completed?" do
    subject { instance }

    context "when there are required steps not yet completed" do
      it { is_expected.not_to be_completed }
    end

    context "when all required steps are completed" do
      let(:school_profile) { create(:school_profile, :completed) }

      it { is_expected.to be_completed }
    end
  end

  describe "#count_completed_sections" do
    subject { instance.count_completed_sections }

    it { is_expected.to be(0) }

    context "when sections are completed" do
      let(:school_profile) { build(:school_profile, :with_admin_contact, :with_key_stage_list, phases_list_primary: true) }

      it { is_expected.to be(2) }
    end
  end
end
