require 'rails_helper'

describe Schools::OnBoarding::CandidateDressCode, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :business_dress }
    it { is_expected.to respond_to :remove_piercings }
    it { is_expected.to respond_to :cover_up_tattoos }
    it { is_expected.to respond_to :remove_piercings }
    it { is_expected.to respond_to :smart_casual }
    it { is_expected.to respond_to :other_dress_requirements }
    it { is_expected.to respond_to :other_dress_requirements_detail }
  end

  context 'validations' do
    it { is_expected.not_to allow_value(nil).for :business_dress }
    it { is_expected.not_to allow_value(nil).for :cover_up_tattoos }
    it { is_expected.not_to allow_value(nil).for :remove_piercings }
    it { is_expected.not_to allow_value(nil).for :smart_casual }
    it { is_expected.not_to allow_value(nil).for :other_dress_requirements }

    context 'when other is not selected' do
      subject { described_class.new other_dress_requirements: false }
      it { is_expected.not_to validate_presence_of :other_dress_requirements_detail }
    end

    context 'when other is selected' do
      subject { described_class.new other_dress_requirements: true }
      it { is_expected.to validate_presence_of :other_dress_requirements_detail }
    end
  end
end
