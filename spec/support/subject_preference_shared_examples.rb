shared_examples 'a subject preference' do
  include_context 'Stubbed candidates school'

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
        described_class::OPTIONS_CONFIG.fetch 'DEGREE_STAGES'
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
        .in_array(described_class::OPTIONS_CONFIG.fetch('DEGREE_SUBJECTS'))
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
        described_class::OPTIONS_CONFIG.fetch('TEACHING_STAGES')
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
      expect(subject.available_subject_choices).to \
        eq school.subjects.pluck :name

      # Test we're passing the correct argument to find as we're stubbing
      # the real return value.
      expect(Candidates::School).to have_received(:find).with(school_urn)
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
end
