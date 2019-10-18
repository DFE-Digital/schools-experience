require 'rails_helper'

describe Schools::OnBoarding::CurrentStep do
  let! :secondary_phase do
    FactoryBot.create :bookings_phase, :secondary
  end

  let! :college_phase do
    FactoryBot.create :bookings_phase, :college
  end

  context '.for' do
    let :returned_step do
      described_class.for school_profile
    end

    context 'dbs_requirement required' do
      let :school_profile do
        FactoryBot.build :school_profile
      end

      it 'returns :dbs_requirement' do
        expect(returned_step).to eq :dbs_requirement
      end
    end

    context 'dbs_requirement not required' do
      let :school_profile do
        FactoryBot.build :school_profile, :with_dbs_requirement
      end

      it 'returns :candidate_requirements_choice' do
        expect(returned_step).to eq :candidate_requirements_choice
      end
    end

    context 'candidate_requirement required' do
      context 'school is not shown candidate_requirement' do
        let :school_profile do
          FactoryBot.build :school_profile, :with_dbs_requirement,
            show_candidate_requirements_selection: false
        end

        it 'returns :candidate_requirement' do
          expect(returned_step).to eq :candidate_requirement
        end
      end

      context 'school is shown select_candidate_requirement' do
        context 'candidate_requirements_choice required' do
          let :school_profile do
            FactoryBot.build :school_profile, :with_dbs_requirement
          end

          it 'returns :candidate_requirements_choice' do
            expect(returned_step).to eq :candidate_requirements_choice
          end
        end

        context 'candidate_requirements_selection not required' do
          let :school_profile do
            FactoryBot.build :school_profile,
              :with_dbs_requirement,
              :without_candidate_requirements_choice,
              show_candidate_requirements_selection: true
          end

          it 'returns :fees' do
            expect(returned_step).to eq :fees
          end
        end

        context 'candidate_requirements_selection required' do
          context 'step not completed' do
            let :school_profile do
              FactoryBot.build :school_profile,
                :with_dbs_requirement,
                :with_candidate_requirements_choice,
                show_candidate_requirements_selection: true
            end

            it 'returns :candidate_requirements_selection' do
              expect(returned_step).to eq :candidate_requirements_selection
            end
          end

          context 'step completed' do
            let :school_profile do
              FactoryBot.build :school_profile,
                :with_dbs_requirement,
                :with_candidate_requirements_choice,
                :with_candidate_requirements_selection,
                show_candidate_requirements_selection: true
            end

            it 'returns :fees' do
              expect(returned_step).to eq :fees
            end
          end
        end
      end
    end

    context 'fees required' do
      let :school_profile do
        FactoryBot.build :school_profile,
          :with_dbs_requirement,
          :with_candidate_requirements_choice,
          :with_candidate_requirements_selection
      end

      it 'returns :fees' do
        expect(returned_step).to eq :fees
      end
    end

    context 'administration_fee required' do
      context 'administration_fee invalid' do
        let :school_profile do
          FactoryBot.build :school_profile,
            :with_dbs_requirement,
            :with_candidate_requirements_choice,
            :with_candidate_requirements_selection,
            fees_administration_fees: true,
            fees_dbs_fees: false,
            fees_other_fees: false
        end

        it 'returns :administration_fee' do
          expect(returned_step).to eq :administration_fee
        end
      end

      context 'administration_fee valid step flagged incomplete' do
        let :school_profile do
          FactoryBot.build :school_profile,
            :with_dbs_requirement,
            :with_candidate_requirements_choice,
            :with_candidate_requirements_selection,
            :with_administration_fee,
            fees_administration_fees: true,
            fees_dbs_fees: true,
            fees_other_fees: false,
            administration_fee_step_completed: false
        end

        it 'returns :administration_fee' do
          expect(returned_step).to eq :administration_fee
        end
      end
    end

    context 'dbs_fee required' do
      context 'dbs_fee invalid' do
        let :school_profile do
          FactoryBot.build :school_profile,
            :with_dbs_requirement,
            :with_candidate_requirements_choice,
            :with_candidate_requirements_selection,
            fees_administration_fees: false,
            fees_dbs_fees: true,
            fees_other_fees: false
        end

        it 'returns :dbs_fee' do
          expect(returned_step).to eq :dbs_fee
        end
      end

      context 'dbs_fee step flagged incomplete' do
        let :school_profile do
          FactoryBot.build :school_profile,
            :with_dbs_requirement,
            :with_candidate_requirements_choice,
            :with_candidate_requirements_selection,
            :with_dbs_fee,
            fees_administration_fees: false,
            fees_dbs_fees: true,
            fees_other_fees: false,
            dbs_fee_step_completed: false
        end

        it 'returns :dbs_fee' do
          expect(returned_step).to eq :dbs_fee
        end
      end
    end

    context 'other_fees required' do
      context 'other_fees invalid' do
        let :school_profile do
          FactoryBot.build :school_profile,
            :with_dbs_requirement,
            :with_candidate_requirements_choice,
            :with_candidate_requirements_selection,
            fees_administration_fees: false,
            fees_dbs_fees: false,
            fees_other_fees: true
        end

        it 'returns :other_fees' do
          expect(returned_step).to eq :other_fee
        end
      end

      context 'other_fees step flagged incomplete' do
        let :school_profile do
          FactoryBot.build :school_profile,
            :with_dbs_requirement,
            :with_candidate_requirements_choice,
            :with_candidate_requirements_selection,
            :with_other_fee,
            fees_administration_fees: false,
            fees_dbs_fees: false,
            fees_other_fees: true,
            other_fee_step_completed: false
        end

        it 'returns :other_fees' do
          expect(returned_step).to eq :other_fee
        end
      end
    end

    context 'phases_list required' do
      let :school_profile do
        FactoryBot.build :school_profile,
          :with_dbs_requirement,
          :with_candidate_requirements_choice,
          :with_candidate_requirements_selection,
          fees_administration_fees: false,
          fees_dbs_fees: false,
          fees_other_fees: false
      end

      it 'returns :phases_list' do
        expect(returned_step).to eq :phases_list
      end
    end

    context 'key_stage_list required' do
      let :school_profile do
        FactoryBot.build :school_profile,
          :with_dbs_requirement,
          :with_candidate_requirements_choice,
          :with_candidate_requirements_selection,
          :with_fees,
          :with_administration_fee,
          :with_dbs_fee,
          :with_other_fee,
          :with_phases
      end

      it 'returns :key_stage_list' do
        expect(returned_step).to eq :key_stage_list
      end
    end

    context 'subjects required' do
      let :school_profile do
        FactoryBot.build :school_profile,
          :with_dbs_requirement,
          :with_candidate_requirements_choice,
          :with_candidate_requirements_selection,
          :with_fees,
          :with_administration_fee,
          :with_dbs_fee,
          :with_other_fee,
          :with_phases,
          :with_key_stage_list
      end

      it 'returns subjects' do
        expect(returned_step).to eq :subjects
      end
    end

    context 'description required' do
      let :school_profile do
        FactoryBot.create :school_profile,
          :with_dbs_requirement,
          :with_candidate_requirements_choice,
          :with_candidate_requirements_selection,
          :with_fees,
          :with_administration_fee,
          :with_dbs_fee,
          :with_other_fee,
          :with_phases,
          :with_key_stage_list,
          :with_subjects
      end

      it 'returns :description' do
        expect(returned_step).to eq :description
      end
    end

    context 'candidate_experience_detail required' do
      let :school_profile do
        FactoryBot.create :school_profile,
          :with_dbs_requirement,
          :with_candidate_requirements_choice,
          :with_candidate_requirements_selection,
          :with_fees,
          :with_administration_fee,
          :with_dbs_fee,
          :with_other_fee,
          :with_phases,
          :with_key_stage_list,
          :with_subjects,
          :with_description
      end

      it 'returns :candidate_experience_detail' do
        expect(returned_step).to eq :candidate_experience_detail
      end
    end

    context 'access_needs_support required' do
      let :school_profile do
        FactoryBot.create :school_profile,
          :with_dbs_requirement,
          :with_candidate_requirements_choice,
          :with_candidate_requirements_selection,
          :with_fees,
          :with_administration_fee,
          :with_dbs_fee,
          :with_other_fee,
          :with_phases,
          :with_key_stage_list,
          :with_subjects,
          :with_description,
          :with_candidate_experience_detail
      end

      it 'returns :access_needs_support' do
        expect(returned_step).to eq :access_needs_support
      end
    end

    context 'access_needs_detail not required' do
      let :school_profile do
        FactoryBot.create :school_profile,
          :with_dbs_requirement,
          :with_candidate_requirements_choice,
          :with_candidate_requirements_selection,
          :with_fees,
          :with_administration_fee,
          :with_dbs_fee,
          :with_other_fee,
          :with_phases,
          :with_key_stage_list,
          :with_subjects,
          :with_description,
          :with_candidate_experience_detail,
          :with_access_needs_support,
          :without_access_needs_support
      end

      it 'returns :experience_outline' do
        expect(returned_step).to eq :experience_outline
      end
    end

    context 'access_needs_detail required' do
      let :school_profile do
        FactoryBot.create :school_profile,
          :with_dbs_requirement,
          :with_candidate_requirements_choice,
          :with_candidate_requirements_selection,
          :with_fees,
          :with_administration_fee,
          :with_dbs_fee,
          :with_other_fee,
          :with_phases,
          :with_key_stage_list,
          :with_subjects,
          :with_description,
          :with_candidate_experience_detail,
          :with_access_needs_support
      end

      it 'returns :access_needs_detail' do
        expect(returned_step).to eq :access_needs_detail
      end
    end

    context 'disability_confident required' do
      let :school_profile do
        FactoryBot.create :school_profile,
          :with_dbs_requirement,
          :with_candidate_requirements_choice,
          :with_candidate_requirements_selection,
          :with_fees,
          :with_administration_fee,
          :with_dbs_fee,
          :with_other_fee,
          :with_phases,
          :with_key_stage_list,
          :with_subjects,
          :with_description,
          :with_candidate_experience_detail,
          :with_access_needs_support,
          :with_access_needs_detail
      end

      it 'returns :disability_confident' do
        expect(returned_step).to eq :disability_confident
      end
    end

    context 'access_needs_policy required' do
      let :school_profile do
        FactoryBot.create :school_profile,
          :with_dbs_requirement,
          :with_candidate_requirements_choice,
          :with_candidate_requirements_selection,
          :with_fees,
          :with_administration_fee,
          :with_dbs_fee,
          :with_other_fee,
          :with_phases,
          :with_key_stage_list,
          :with_subjects,
          :with_description,
          :with_candidate_experience_detail,
          :with_access_needs_support,
          :with_access_needs_detail,
          :with_disability_confident
      end

      it 'returns :access_needs_policy' do
        expect(returned_step).to eq :access_needs_policy
      end
    end

    context 'experience_outline requred' do
      let :school_profile do
        FactoryBot.create :school_profile,
          :with_dbs_requirement,
          :with_candidate_requirements_choice,
          :with_candidate_requirements_selection,
          :with_fees,
          :with_administration_fee,
          :with_dbs_fee,
          :with_other_fee,
          :with_phases,
          :with_key_stage_list,
          :with_subjects,
          :with_description,
          :with_candidate_experience_detail,
          :with_access_needs_support,
          :with_access_needs_detail,
          :with_disability_confident,
          :with_access_needs_policy
      end

      it 'returns :experience_outline' do
        expect(returned_step).to eq :experience_outline
      end
    end

    context 'admin_contact required' do
      let :school_profile do
        FactoryBot.create :school_profile,
          :with_dbs_requirement,
          :with_candidate_requirements_choice,
          :with_candidate_requirements_selection,
          :with_fees,
          :with_administration_fee,
          :with_dbs_fee,
          :with_other_fee,
          :with_phases,
          :with_key_stage_list,
          :with_subjects,
          :with_description,
          :with_candidate_experience_detail,
          :with_access_needs_support,
          :with_access_needs_detail,
          :with_disability_confident,
          :with_access_needs_policy,
          :with_experience_outline
      end

      it 'returns :admin_contact' do
        expect(returned_step).to eq :admin_contact
      end
    end

    context 'admin_contact not required' do
      let :school_profile do
        FactoryBot.create :school_profile,
          :with_dbs_requirement,
          :with_candidate_requirements_choice,
          :with_candidate_requirements_selection,
          :with_fees,
          :with_administration_fee,
          :with_dbs_fee,
          :with_other_fee,
          :with_phases,
          :with_key_stage_list,
          :with_subjects,
          :with_description,
          :with_candidate_experience_detail,
          :with_access_needs_support,
          :with_access_needs_detail,
          :with_disability_confident,
          :with_access_needs_policy,
          :with_experience_outline,
          :with_admin_contact
      end

      it 'returns :COMPLETED' do
        expect(returned_step).to eq :COMPLETED
      end
    end
  end
end
