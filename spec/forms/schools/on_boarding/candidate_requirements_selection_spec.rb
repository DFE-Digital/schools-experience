require 'rails_helper'

describe Schools::OnBoarding::CandidateRequirementsSelection, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :on_teacher_training_course }
    it { is_expected.to respond_to :not_on_another_training_course }
    it { is_expected.to respond_to :has_or_working_towards_degree }
    it { is_expected.to respond_to :live_locally }
    it { is_expected.to respond_to :maximum_distance_from_school }
    it { is_expected.to respond_to :provide_photo_identification }
    it { is_expected.to respond_to :photo_identification_details }
    it { is_expected.to respond_to :other }
    it { is_expected.to respond_to :other_details }
  end

  context 'before_validation' do
    context 'when the live_locally option is selected' do
      before do
        subject.live_locally = true
        subject.maximum_distance_from_school = 7
        subject.valid?
      end

      it 'doesnt removes maximum_distance_from_school' do
        expect(subject.maximum_distance_from_school).to eq 7
      end
    end

    context 'when the live_locally option is not selected' do
      before do
        subject.live_locally = false
        subject.maximum_distance_from_school = 7
        subject.valid?
      end

      it 'removes maximum_distance_from_school' do
        expect(subject.maximum_distance_from_school).to be nil
      end
    end

    context 'when provide_photo_identification is selected' do
      before do
        subject.provide_photo_identification = true
        subject.photo_identification_details = 'photo details'
        subject.valid?
      end

      it 'doesnt remove photo_identification_details' do
        expect(subject.photo_identification_details).to eq 'photo details'
      end
    end

    context 'when provide_photo_identification is not selected' do
      before do
        subject.provide_photo_identification = false
        subject.photo_identification_details = 'photo details'
        subject.valid?
      end

      it 'removes photo_identification_details' do
        expect(subject.photo_identification_details).to be nil
      end
    end

    context 'when other option is selected' do
      before do
        subject.other = true
        subject.other_details = 'some details'
        subject.valid?
      end

      it 'doesnt remove other_details' do
        expect(subject.other_details).to eq 'some details'
      end
    end

    context 'when other option is not selected' do
      before do
        subject.other = false
        subject.other_details = 'some details'
        subject.valid?
      end

      it 'removes other_details' do
        expect(subject.other_details).to be nil
      end
    end
  end

  context 'validations' do
    context 'maximum_distance_from_school' do
      context 'when the live_locally is selected' do
        before { subject.live_locally = true }
        it { is_expected.to validate_presence_of :maximum_distance_from_school }
      end

      context 'when the live_locally is not selected' do
        before { subject.live_locally = false }
        it { is_expected.not_to validate_presence_of :maximum_distance_from_school }
      end
    end

    context 'photo_identification_details' do
      context 'when provide_photo_identification is selected' do
        before { subject.provide_photo_identification = true }
        it { is_expected.to validate_presence_of :photo_identification_details }
      end

      context 'when provide_photo_identification is not selected' do
        before { subject.provide_photo_identification = false }
        it { is_expected.not_to validate_presence_of :photo_identification_details }
      end
    end

    context 'other details' do
      context 'when other is selected' do
        before { subject.other = true }
        it { is_expected.to validate_presence_of :other_details }
      end

      context 'when other is not select' do
        before { subject.other = false }
        it { is_expected.not_to validate_presence_of :other_details }
      end
    end
  end
end
