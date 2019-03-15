require 'rails_helper'

describe Schools::SchoolProfile, type: :model do
  context 'candidate_requirement' do
    context 'attributes' do
      it do
        is_expected.to have_db_column(:urn).of_type :integer
      end

      it do
        is_expected.to \
          have_db_column(:candidate_requirement_dbs_requirement).of_type :string
      end

      it do
        is_expected.to \
          have_db_column(:candidate_requirement_dbs_policy).of_type :text
      end

      it do
        is_expected.to \
          have_db_column(:candidate_requirement_requirements).of_type :boolean
      end

      it do
        is_expected.to \
          have_db_column(:candidate_requirement_requirements_details).of_type :text
      end
    end

    context 'validations' do
      it do
        is_expected.to validate_presence_of :urn
      end
    end

    context 'values from form models' do
      let :model do
        described_class.new urn: 1234567890
      end

      context '#candidate_requirement' do
        let :form_model do
          FactoryBot.build :candidate_requirement
        end

        before do
          model.candidate_requirement = form_model
        end

        it 'sets candidate_requirement_dbs_requirement' do
          expect(model.candidate_requirement_dbs_requirement).to eq \
            form_model.dbs_requirement
        end

        it 'sets candidate_requirement_dbs_policy' do
          expect(model.candidate_requirement_dbs_policy).to eq \
            form_model.dbs_policy
        end

        it 'sets candidate_requirement_requirements' do
          expect(model.candidate_requirement_requirements).to eq \
            form_model.requirements
        end

        it 'sets candidate_requirement_requirements_details' do
          expect(model.candidate_requirement_requirements_details).to eq \
            form_model.requirements_details
        end

        it 'returns the form model' do
          expect(model.candidate_requirement).to eq form_model
        end
      end
    end

    context '#completed?' do
      let :model do
        described_class.new urn: 1234567890
      end

      context 'without candidate_requirement' do
        it 'returns false' do
          expect(model.completed?).to be false
        end
      end

      context 'with candidate_requirement' do
        context 'when candidate_requirement invalid' do
          before do
            model.candidate_requirement = FactoryBot.build(
              :candidate_requirement,
              dbs_requirement: nil
            )
          end

          it 'returns false' do
            expect(model.completed?).to be false
          end
        end

        context 'when candidate_requirement valid' do
          before do
            model.candidate_requirement = FactoryBot.build :candidate_requirement
          end

          it 'returns true' do
            expect(model.completed?).to be true
          end
        end
      end
    end
  end
end
