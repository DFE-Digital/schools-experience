require 'rails_helper'

describe Schools::OnBoarding::ExperienceOutline, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :candidate_experience }
    it { is_expected.to respond_to :provides_teacher_training }
    it { is_expected.to respond_to :teacher_training_details }
    it { is_expected.to respond_to :teacher_training_url }
  end

  context 'validates' do
    it { is_expected.to validate_presence_of :candidate_experience }
    it { is_expected.not_to allow_value(nil).for :provides_teacher_training }

    context 'when provides_teacher_training' do
      subject { described_class.new provides_teacher_training: true }
      it { is_expected.to validate_presence_of :teacher_training_details }
      it { is_expected.to validate_presence_of :teacher_training_url }
    end

    context 'when not provides_teacher_training' do
      subject { described_class.new provides_teacher_training: false }
      it { is_expected.not_to validate_presence_of :teacher_training_details }
      it { is_expected.not_to validate_presence_of :teacher_training_url }
    end
  end
end
