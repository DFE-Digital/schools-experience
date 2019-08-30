require 'rails_helper'

describe Schools::OnBoarding::CandidateRequirement, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :requirements }
    it { is_expected.to respond_to :requirements_details }
  end

  context 'validations' do
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
