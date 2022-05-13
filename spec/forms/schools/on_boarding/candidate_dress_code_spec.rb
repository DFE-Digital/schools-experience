require 'rails_helper'

describe Schools::OnBoarding::CandidateDressCode, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :selected_requirements }
    it { is_expected.to respond_to :other_dress_requirements_detail }
  end

  context 'validations' do
    describe "#other_dress_requirements_detail" do
      context 'when other is not selected' do
        subject { described_class.new(selected_requirements: []) }

        it { is_expected.not_to validate_presence_of :other_dress_requirements_detail }
      end

      context 'when other is selected' do
        subject { described_class.new(selected_requirements: %w[other_dress_requirements]) }

        it { is_expected.to validate_presence_of :other_dress_requirements_detail }
      end
    end

    describe "#selected_requirements" do
      context "when no options are selected" do
        subject { described_class.new(selected_requirements: []) }

        it { expect(subject).to be_invalid }
      end

      context "when requirement and no requirements are selected" do
        subject { described_class.new(selected_requirements: %w[business_dress none]) }

        it { expect(subject).to be_invalid }
      end
    end
  end
end
