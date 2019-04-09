require 'rails_helper'

describe Schools::OnBoarding::CandidateRequirement, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :dbs_requirement }
    it { is_expected.to respond_to :dbs_policy }
    it { is_expected.to respond_to :requirements }
    it { is_expected.to respond_to :requirements_details }
  end

  context 'validations' do
    context 'dbs_requirement' do
      it { is_expected.to validate_presence_of(:dbs_requirement) }
      it do
        is_expected.to validate_inclusion_of(:dbs_requirement).in_array \
          %w(always sometimes never)
      end

      context "when dbs_requirement is 'Yes - sometimes'" do
        subject { described_class.new dbs_requirement: 'sometimes' }

        it do
          is_expected.to validate_presence_of :dbs_policy
        end
      end

      context "when dbs_requirement not 'Yes - sometimes'" do
        subject { described_class.new dbs_requirement: 'never' }

        it do
          is_expected.not_to validate_presence_of :dbs_policy
        end
      end
    end

    context 'requirements' do
      it do
        is_expected.not_to allow_value(nil).for :requirements
      end

      context 'when requirements is true' do
        subject { described_class.new requirements: true }

        it do
          is_expected.to validate_presence_of :requirements_details
        end
      end

      context 'when requirements is false' do
        subject { described_class.new requirements: false }

        it do
          is_expected.not_to validate_presence_of :requirements_details
        end
      end
    end
  end
end
