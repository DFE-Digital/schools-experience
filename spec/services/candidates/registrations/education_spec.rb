require 'rails_helper'

describe Candidates::Registrations::Education, type: :model do
  include_context 'Stubbed candidates school'
  it_behaves_like 'a registration step'

  context 'attributes' do
    it { is_expected.to respond_to :degree_stage }
    it { is_expected.to respond_to :degree_stage_explaination }
    it { is_expected.to respond_to :degree_subject }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :degree_stage }

    it do
      is_expected.to validate_inclusion_of(:degree_stage).in_array \
        described_class::OPTIONS_CONFIG.fetch 'DEGREE_STAGES'
    end

    context 'when degree stage is "Other"' do
      subject { FactoryBot.build :education, degree_stage: 'Other' }

      it { is_expected.to validate_presence_of :degree_stage_explaination }
    end

    context 'when degree stage is not "Other"' do
      it { is_expected.not_to validate_presence_of :degree_stage_explaination }
    end

    it { is_expected.to validate_presence_of :degree_subject }

    context 'when degree stage is "I don\'t have a degree and am not studying for one"' do
      subject do
        FactoryBot.build :education,
          degree_stage: "I don't have a degree and am not studying for one"
      end

      it do
        is_expected.to validate_absence_of(:degree_subject)
      end
    end

    context 'when degree stage is not "I don\'t have a degree and am not studying for one"' do
      subject do
        FactoryBot.build :education, degree_stage: 'Final year'
      end

      it do
        is_expected.to validate_presence_of(:degree_subject)
      end
    end
  end

  context '#requires_subject_for_degree_stage?' do
    let :result do
      described_class.new.requires_subject_for_degree_stage? stage
    end

    context 'when degree stage does not require subject' do
      let :stage do
        "I don't have a degree and am not studying for one"
      end

      it 'returns false' do
        expect(result).to be false
      end
    end

    context 'when degree stage requires subject' do
      let :stage do
        "Graduate or postgraduate"
      end

      it 'returns true' do
        expect(result).to be true
      end
    end
  end

  describe '#degree_subject_autocomplete?' do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("DEGREE_SUBJECT_AUTOCOMPLETE_ENABLED", false).and_return(degree_subject_autocomplete_flag)
    end

    context "when DEGREE_SUBJECT_AUTOCOMPLETE_ENABLED is not set" do
      let(:degree_subject_autocomplete_flag) { nil }

      it "returns false" do
        expect(subject).not_to be_degree_subject_autocomplete
      end
    end

    context "when DEGREE_SUBJECT_AUTOCOMPLETE_ENABLED=0" do
      let(:degree_subject_autocomplete_flag) { "0" }

      it "returns false" do
        expect(subject).not_to be_degree_subject_autocomplete
      end
    end

    context "when DEGREE_SUBJECT_AUTOCOMPLETE_ENABLED=1" do
      let(:degree_subject_autocomplete_flag) { "1" }

      it "returns true" do
        expect(subject).to be_degree_subject_autocomplete
      end
    end
  end
end
