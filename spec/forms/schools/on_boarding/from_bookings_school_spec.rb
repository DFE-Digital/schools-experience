require 'rails_helper'

describe Schools::OnBoarding::FromBookingsSchool do
  subject { described_class.new school }

  context '#[]' do
    context 'availability_description' do
      let :school do
        FactoryBot.build :bookings_school
      end

      it 'returns the correct attributes' do
        expect(subject['availability_description']).to \
          eq description: school.availability_info
      end
    end

    context 'availability_preference' do
      context 'when the school has availability_info' do
        let :school do
          FactoryBot.build :bookings_school
        end

        it 'returns the correct attributes' do
          expect(subject['availability_preference']).to eq fixed: false
        end
      end

      context 'when the school does not have availability_info' do
        let :school do
          FactoryBot.build :bookings_school, availability_info: nil
        end

        it 'returns the correct attributes' do
          expect(subject['availability_preference']).to eq fixed: nil
        end
      end
    end

    context 'experience_outline' do
      let :school do
        FactoryBot.build :bookings_school,
          :with_placement_info,
          :with_teacher_training_info,
          :with_teacher_training_website,
          teacher_training_provider: true
      end

      it 'returns the correct attributes' do
        expect(subject['experience_outline']).to eq \
          candidate_experience: school.placement_info,
          provides_teacher_training: school.teacher_training_provider.presence,
          teacher_training_details: school.teacher_training_info,
          teacher_training_url: school.teacher_training_website
      end

      context 'provides_teacher_training' do
        context 'when the school provides teacher training' do
          let :school do
            FactoryBot.build :bookings_school, teacher_training_provider: true
          end

          it 'returns the correct attributes' do
            expect(
              subject['experience_outline'][:provides_teacher_training]
            ).to eq true
          end
        end

        context 'when the school does not provide teacher training' do
          let :school do
            FactoryBot.build :bookings_school, teacher_training_provider: false
          end

          it 'returns the correct attributes' do
            expect(
              subject['experience_outline'][:provides_teacher_training]
            ).to eq nil
          end
        end
      end
    end

    context 'key_stage_list' do
      context 'when has early years' do
        let :school do
          FactoryBot.build :bookings_school,
            primary_key_stage_info: 'Early years foundation stage (EYFS)'
        end

        it 'returns the correct value for early_years' do
          expect(subject['key_stage_list'][:early_years]).to be true
        end
      end

      context 'when does not have early years' do
        let :school do
          FactoryBot.build :bookings_school,
            primary_key_stage_info: 'Key stage 1'
        end

        it 'returns the correct value for early_years' do
          expect(subject['key_stage_list'][:early_years]).to be false
        end
      end

      context 'when has key stage 1' do
        let :school do
          FactoryBot.build :bookings_school,
            primary_key_stage_info: 'Key stage 1'
        end

        it 'returns the correct value for key_stage_1' do
          expect(subject['key_stage_list'][:key_stage_1]).to be true
        end
      end

      context 'when does not have key stage 1' do
        let :school do
          FactoryBot.build :bookings_school,
            primary_key_stage_info: 'Key stage 2'
        end

        it 'returns the correct value for key_stage_1' do
          expect(subject['key_stage_list'][:key_stage_1]).to be false
        end
      end

      context 'when has key stage 2' do
        let :school do
          FactoryBot.build :bookings_school,
            primary_key_stage_info: 'Key stage 2'
        end

        it 'returns the correct value for key_stage_2' do
          expect(subject['key_stage_list'][:key_stage_2]).to be true
        end
      end

      context 'when does not have key stage 2' do
        let :school do
          FactoryBot.build :bookings_school,
            primary_key_stage_info: 'Early years foundation stage (EYFS)'
        end

        it 'returns the correct value for key_stage_2' do
          expect(subject['key_stage_list'][:key_stage_2]).to be false
        end
      end
    end

    context 'phases_list' do
      context 'when primary_key_stage_info is present' do
        let :school do
          FactoryBot.build :bookings_school, :with_primary_key_stage_info
        end

        it 'returns the correct attributes' do
          expect(subject['phases_list']).to eq primary: true
        end
      end

      context 'when primary_key_stage_info is not present' do
        let :school do
          FactoryBot.build :bookings_school
        end

        it 'returns the correct attributes' do
          expect(subject['phases_list']).to eq primary: false
        end
      end
    end

    context 'subject_list' do
      let :school do
        FactoryBot.create :bookings_school, :with_subjects
      end

      it 'returns the correct attributes' do
        expect(subject['subject_list']).to eq subject_ids: school.subject_ids
      end
    end
  end
end
