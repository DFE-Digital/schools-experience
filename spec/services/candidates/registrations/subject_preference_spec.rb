require 'rails_helper'

describe Candidates::Registrations::SubjectPreference, type: :model do
  let :school_urn do
    'URN'
  end

  let :subjects do
    [
      { name: 'Geography' }
    ]
  end

  let :school do
    double Bookings::School, id: school_urn, subjects: subjects
  end

  let :allowed_subject_choices do
    school.subjects.pluck :name
  end

  before do
    allow(Candidates::School).to receive(:find) { school }
  end

  subject { described_class.new urn: school_urn }

  context 'attributes' do
    it { is_expected.to respond_to :urn }
    it { is_expected.to respond_to :degree_stage }
    it { is_expected.to respond_to :degree_stage_explaination }
    it { is_expected.to respond_to :degree_subject }
    it { is_expected.to respond_to :teaching_stage }
    it { is_expected.to respond_to :subject_first_choice }
    it { is_expected.to respond_to :subject_second_choice }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :urn }

    it { is_expected.to validate_presence_of :degree_stage }

    it do
      is_expected.to validate_inclusion_of(:degree_stage).in_array \
        described_class.degree_stages
    end

    context 'when degree stage is "Other"' do
      before do
        allow(subject).to receive(:degree_stage) { "Other" }
      end

      it { is_expected.to validate_presence_of :degree_stage_explaination }
    end

    context 'when degree stage is not "Other"' do
      it { is_expected.not_to validate_presence_of :degree_stage_explaination }
    end

    it { is_expected.to validate_presence_of :degree_subject }

    it do
      is_expected.to validate_inclusion_of(:degree_subject)
        .in_array(described_class.degree_subjects)
        .with_message('Select a subject')
    end

    context 'when degree stage is "I don\'t have a degree and am not studying for one"' do
      before do
        allow(subject).to receive(:degree_stage) { "I don't have a degree and am not studying for one" }
      end

      it do
        is_expected.to validate_inclusion_of(:degree_subject).in_array \
          ['Not applicable']
      end
    end

    context 'when degree stage is not "I don\'t have a degree and am not studying for one"' do
      before do
        allow(subject).to receive(:degree_stage) { 'Final year' }
      end

      it do
        is_expected.to validate_exclusion_of(:degree_subject).in_array \
          ['Not applicable']
      end
    end

    it { is_expected.to validate_presence_of :teaching_stage }

    it do
      is_expected.to validate_inclusion_of(:teaching_stage).in_array \
        described_class.teaching_stages
    end

    it { is_expected.to validate_presence_of :subject_first_choice }

    it do
      is_expected.to validate_inclusion_of(:subject_first_choice).in_array \
        allowed_subject_choices
    end

    it { is_expected.to validate_presence_of :subject_second_choice }

    it do
      is_expected.to validate_inclusion_of(:subject_second_choice).in_array \
        allowed_subject_choices
    end
  end

  context '#subject_choices' do
    it "returns the list of subjects from it's school" do
      expect(subject.subject_choices).to eq school.subjects.pluck :name

      # Test we're passing the correct argument to find as we're stubbing
      # the real return value.
      expect(Candidates::School).to have_received(:find).with(school_urn)
    end
  end
end
