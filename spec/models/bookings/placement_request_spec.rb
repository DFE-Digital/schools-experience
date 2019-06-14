require 'rails_helper'

describe Bookings::PlacementRequest, type: :model do
  include_context 'Stubbed candidates school'
  subject { described_class.new bookings_school_id: school.id }

  it { is_expected.to have_db_column(:objectives).of_type(:text).with_options null: false }
  it { is_expected.to have_db_column(:urn).of_type(:integer).with_options null: false }
  it { is_expected.to have_db_column(:degree_stage).of_type(:string).with_options null: false }
  it { is_expected.to have_db_column(:degree_stage_explaination).of_type :text }
  it { is_expected.to have_db_column(:degree_subject).of_type(:string).with_options null: false }
  it { is_expected.to have_db_column(:teaching_stage).of_type(:string).with_options null: false }
  it { is_expected.to have_db_column(:subject_first_choice).of_type(:string).with_options null: false }
  it { is_expected.to have_db_column(:subject_second_choice).of_type(:string).with_options null: false }
  it { is_expected.to have_db_column(:has_dbs_check).of_type(:boolean).with_options null: false }
  it { is_expected.to have_db_column(:availability).of_type(:text).with_options null: true }
  it { is_expected.to have_db_column(:bookings_placement_date_id).of_type(:integer).with_options null: true }
  it { is_expected.to have_db_column(:analytics_tracking_uuid).of_type(:uuid).with_options null: true }

  it { is_expected.to have_secure_token }

  context 'relationships' do
    it do
      is_expected.to \
        have_one(:candidate_cancellation)
          .dependent(:destroy)
          .class_name('Bookings::PlacementRequest::Cancellation')
    end

    it do
      is_expected.to \
        have_one(:school_cancellation)
          .dependent(:destroy)
          .class_name('Bookings::PlacementRequest::Cancellation')
    end

    it { is_expected.to belong_to(:school).class_name('Bookings::School').with_foreign_key(:bookings_school_id) }
    it { is_expected.to have_one(:booking).class_name('Bookings::Booking').with_foreign_key(:bookings_placement_request_id) }
    it { is_expected.to belong_to(:placement_date).class_name('Bookings::PlacementDate').with_foreign_key(:bookings_placement_date_id).optional }
  end

  it { is_expected.to respond_to :sent_at }

  it_behaves_like 'a background check'

  context '.open' do
    let :school do
      FactoryBot.create :bookings_school, :with_subjects
    end

    let! :placement_request_closed_by_candidate do
      FactoryBot.create :placement_request, :cancelled, school: school
    end

    let! :placement_request_closed_by_school do
      FactoryBot.create :placement_request, :cancelled_by_school, school: school
    end

    let! :placement_request_with_booking do
      FactoryBot.create(:bookings_booking).bookings_placement_request
    end

    let! :placement_request_open do
      FactoryBot.create :placement_request, school: school
    end

    it 'only returns the open placement requests' do
      expect(described_class.open).to match_array [placement_request_open]
      expect(described_class.open).not_to include placement_request_closed_by_candidate
      expect(described_class.open).not_to include placement_request_closed_by_school
      expect(described_class.open).not_to include placement_request_with_booking
    end
  end

  context '.create_from_registration_session' do
    context 'invalid session' do
      let :invalid_session do
        Candidates::Registrations::RegistrationSession.new \
          "candidates_registrations_background_check" => {},
          "candidates_registrations_contact_information" => {},
          "candidates_registrations_placement_preference" => {},
          "candidates_registrations_subject_preference" => {},
          "urn" => 123456
      end

      it 'raises a validation error' do
        expect {
          described_class.create_from_registration_session! invalid_session
        }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context 'valid session' do
      include_context 'Stubbed candidates school'

      let :registration_session do
        FactoryBot.build :registration_session
      end

      it 'creates the placement request' do
        expect {
          described_class.create_from_registration_session! registration_session
        }.to change { described_class.count }.by 1
      end
    end

    context 'with analytics_tracking_uuid' do
      let! :analytics_tracking_uuid do
        SecureRandom.uuid
      end

      let :registration_session do
        FactoryBot.build :registration_session
      end

      subject do
        described_class.create_from_registration_session! registration_session, analytics_tracking_uuid
      end

      specify 'it stores the analytics_tracking_uuid correctly if supplied' do
        expect(subject.analytics_tracking_uuid).to eql(analytics_tracking_uuid)
      end
    end
  end

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
        second_subject_choices
    end
  end

  context '#available_subject_choices' do
    context 'when the school has subjects' do
      before do
        school.subjects << FactoryBot.build_list(:bookings_subject, 8)
      end

      it "returns the list of subjects from it's school" do
        expect(subject.available_subject_choices).to \
          eq school.subjects.pluck(:name)
      end
    end

    context "when the school doesn't have subjects" do
      it 'returns the list of all subjects' do
        expect(subject.available_subject_choices).to \
          eq Candidates::School.subjects.map(&:last)
      end
    end
  end

  context '#second_subject_choices' do
    it "returns the list of subjects from it's school" do
      choices = subject.second_subject_choices
      no_choice = choices.shift

      expect(choices).to \
        eq subject.available_subject_choices

      expect(no_choice).to match(/don't have/)
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

  let! :today do
    Date.today
  end

  context 'attributes' do
    it { is_expected.to respond_to :urn }
    it { is_expected.to respond_to :availability }
    it { is_expected.to respond_to :objectives }
    it { is_expected.to respond_to :bookings_placement_date_id }
  end

  context 'validations' do
    before :each do
      placement_preference.validate
    end

    context 'when the school allows flexible dates' do
      let(:placement_preference) { described_class.new(bookings_school_id: school.id) }
      context 'when availability are not present' do
        let :placement_preference do
          described_class.new
        end

        it 'adds an error to availability' do
          expect(placement_preference.errors[:availability]).to eq \
            ["Enter your availability"]
        end
      end

      context 'when availability are too long' do
        let :placement_preference do
          described_class.new \
            availability: 151.times.map { 'word' }.join(' ')
        end

        it 'adds an error to availability' do
          expect(placement_preference.errors[:availability]).to eq \
            ["Use 150 words or fewer"]
        end
      end
    end

    context 'when the school mandates fixed dates' do
      before do
        allow(placement_preference).to receive(:school_offers_fixed_dates?).and_return(true)
      end

      let(:placement_preference) { described_class.new(bookings_school_id: school.id) }

      before(:each) { placement_preference.validate }

      it 'adds an error to bookings_placement_date_id' do
        expect(placement_preference.errors[:bookings_placement_date_id]).to include \
          "Choose a placement date"
      end
    end

    context 'when objectives are not present' do
      let :placement_preference do
        described_class.new
      end

      it 'adds an error to objectives' do
        expect(placement_preference.errors[:objectives]).to eq \
          ["Enter what you want to get out of a placement"]
      end
    end

    context 'when objectives are too long' do
      let :placement_preference do
        described_class.new \
          objectives: 151.times.map { 'word' }.join(' ')
      end

      it 'adds an error to objectives' do
        expect(placement_preference.errors[:objectives]).to eq \
          ["Use 150 words or fewer"]
      end
    end
  end

  context '#closed?' do
    context 'when cancelled' do
      context 'when cancelled by candidate' do
        subject { FactoryBot.create :placement_request, :cancelled }

        it 'returns true' do
          expect(subject).to be_closed
        end
      end

      context 'when cancelled by school' do
        subject { FactoryBot.create :placement_request, :cancelled_by_school }

        it 'returns true' do
          expect(subject).to be_closed
        end
      end
    end

    context 'when not cancelled' do
      subject { FactoryBot.create :placement_request }

      it 'returns false' do
        expect(subject).not_to be_closed
      end
    end
  end

  context 'build_candidate_cancellation' do
    let :cancellation do
      described_class.new.build_candidate_cancellation
    end

    it 'returns a new cancellation with cancelled_by set to "candidate"' do
      expect(cancellation.cancelled_by).to eq 'candidate'
    end
  end

  context 'build_school_cancellation' do
    let :cancellation do
      described_class.new.build_school_cancellation
    end

    it 'returns a new cancellation with cancelled_by set to "school"' do
      expect(cancellation.cancelled_by).to eq 'school'
    end
  end

  context '#status' do
    context 'default' do
      subject { FactoryBot.create :placement_request }

      it "returns 'pending'" do
        expect(subject.status).to eq 'New'
      end
    end

    context 'when cancelled?' do
      subject { FactoryBot.create :placement_request, :cancelled }

      it "returns 'cancelled'" do
        expect(subject.status).to eq 'Cancelled'
      end
    end
  end

  context '#dbs' do
    context 'when has_dbs_check' do
      subject { FactoryBot.create :placement_request, has_dbs_check: true }

      it "returns 'Yes'" do
        expect(subject.dbs).to eq 'Yes'
      end
    end

    context 'when not has_dbs_check' do
      subject { FactoryBot.create :placement_request, has_dbs_check: false }

      it "returns 'No'" do
        expect(subject.dbs).to eq 'No'
      end
    end
  end
end
