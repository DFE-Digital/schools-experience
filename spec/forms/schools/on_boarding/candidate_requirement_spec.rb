require 'rails_helper'

describe Schools::OnBoarding::CandidateRequirement, type: :model do
  context 'with attributes' do
    it { is_expected.to respond_to :requirements }
    it { is_expected.to respond_to :requirements_details }
  end

  context 'when validating' do
    context 'when requirements' do
      it do
        expect(subject).not_to allow_value(nil).for :requirements
      end

      context 'when requirements is true' do
        subject { described_class.new requirements: true }

        it do
          expect(subject).to validate_presence_of :requirements_details
        end
      end

      context 'when requirements is false' do
        subject { described_class.new requirements: false }

        it do
          expect(subject).not_to validate_presence_of :requirements_details
        end
      end
    end
  end
end
