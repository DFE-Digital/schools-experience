require 'rails_helper'

describe Schools::OnBoarding::CandidateRequirementsSelection, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :selected_requirements }
    it { is_expected.to respond_to :maximum_distance_from_school }
    it { is_expected.to respond_to :photo_identification_details }
    it { is_expected.to respond_to :other_details }
  end

  context 'before_validation' do
    context 'when the live_locally option is selected' do
      before do
        subject.selected_requirements = %w[live_locally]
        subject.maximum_distance_from_school = 7
        subject.valid?
      end

      it 'doesnt removes maximum_distance_from_school' do
        expect(subject.maximum_distance_from_school).to eq 7
      end
    end

    context 'when the live_locally option is not selected' do
      before do
        subject.maximum_distance_from_school = 7
        subject.valid?
      end

      it 'removes maximum_distance_from_school' do
        expect(subject.maximum_distance_from_school).to be nil
      end
    end

    context 'when provide_photo_identification is selected' do
      before do
        subject.selected_requirements = %w[provide_photo_identification]
        subject.photo_identification_details = 'photo details'
        subject.valid?
      end

      it 'doesnt remove photo_identification_details' do
        expect(subject.photo_identification_details).to eq 'photo details'
      end
    end

    context 'when provide_photo_identification is not selected' do
      before do
        subject.photo_identification_details = 'photo details'
        subject.valid?
      end

      it 'removes photo_identification_details' do
        expect(subject.photo_identification_details).to be nil
      end
    end

    context 'when other option is selected' do
      before do
        subject.selected_requirements = %w[other]
        subject.other_details = 'some details'
        subject.valid?
      end

      it 'doesnt remove other_details' do
        expect(subject.other_details).to eq 'some details'
      end
    end

    context 'when other option is not selected' do
      before do
        subject.other_details = 'some details'
        subject.valid?
      end

      it 'removes other_details' do
        expect(subject.other_details).to be nil
      end
    end
  end

  context 'validations' do
    describe "#selected_requirements" do
      context "when no options are selected" do
        subject { described_class.new(selected_requirements: []) }

        it { expect(subject).to be_invalid }
      end

      context "when requirement and no requirements are selected" do
        subject { described_class.new(selected_requirements: %w[on_teacher_training_course none]) }

        it { expect(subject).to be_invalid }
      end
    end

    context 'maximum_distance_from_school' do
      context 'when the live_locally is selected' do
        before { subject.selected_requirements = %w[live_locally] }
        it { is_expected.to validate_presence_of :maximum_distance_from_school }
      end

      context 'when the live_locally is not selected' do
        it { is_expected.not_to validate_presence_of :maximum_distance_from_school }
      end
    end

    context 'photo_identification_details' do
      context 'when provide_photo_identification is selected' do
        before { subject.selected_requirements = %w[provide_photo_identification] }
        it { is_expected.to validate_presence_of :photo_identification_details }
      end

      context 'when provide_photo_identification is not selected' do
        it { is_expected.not_to validate_presence_of :photo_identification_details }
      end
    end

    context 'other details' do
      context 'when other is selected' do
        before { subject.selected_requirements = %w[other] }
        it { is_expected.to validate_presence_of :other_details }
      end

      context 'when other is not select' do
        it { is_expected.not_to validate_presence_of :other_details }
      end
    end
  end
end
