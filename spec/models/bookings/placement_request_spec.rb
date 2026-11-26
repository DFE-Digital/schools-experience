require 'rails_helper'

describe Bookings::PlacementRequest, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  subject { described_class.new bookings_school_id: school.id }

  include_context 'with a stubbed candidate school'

  let! :today do
    Time.zone.today
  end

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
  it { is_expected.to have_db_column(:candidate_id).of_type(:integer).with_options null: true }
  it { is_expected.to have_db_column(:under_consideration_at).of_type(:datetime).with_options null: true }

  it { is_expected.to have_secure_token }

  describe 'Constants' do
    describe 'EXPERIENCE_TYPES' do
      it 'returns an array of strings' do
        expect(described_class::EXPERIENCE_TYPES).to eq %w[inschool virtual]
      end
    end
  end

  describe 'candidate requirement' do
    it { is_expected.to validate_presence_of :candidate }

    context 'with legacy record' do
      subject { create(:placement_request) }

      before { subject.update_columns(candidate_id: nil)
subject.reload  }

      it { is_expected.to be_valid }
    end
  end

  context 'with relationships' do
    it do
      expect(subject).to \
        have_one(:candidate_cancellation)
          .dependent(:destroy)
          .class_name('Bookings::PlacementRequest::Cancellation')
    end

    it do
      expect(subject).to \
        have_one(:school_cancellation)
          .dependent(:destroy)
          .class_name('Bookings::PlacementRequest::Cancellation')
    end

    it { is_expected.to belong_to(:school).class_name('Bookings::School').with_foreign_key(:bookings_school_id) }
    it { is_expected.to have_one(:booking).class_name('Bookings::Booking').with_foreign_key(:bookings_placement_request_id) }
    it { is_expected.to belong_to(:placement_date).class_name('Bookings::PlacementDate').with_foreign_key(:bookings_placement_date_id).optional }

    it do
      expect(subject).to belong_to(:candidate).class_name('Bookings::Candidate')\
        .with_foreign_key(:candidate_id).without_validating_presence
    end
  end

  it { is_expected.to respond_to :sent_at }

  it_behaves_like 'a background check'

  context 'when scopes' do
    let :school do
      FactoryBot.create :bookings_school, :with_subjects
    end

    let! :placement_request_closed_by_candidate do
      FactoryBot.create :placement_request, :cancelled, school: school
    end

    let! :placement_request_closed_by_school do
      FactoryBot.create :placement_request, :cancelled_by_school, school: school
    end

    let! :placement_request_cancelled_by_school_but_not_sent do
      FactoryBot.create :placement_request, :with_school_cancellation, school: school
    end

    let! :booked_placement_request do
      FactoryBot.create(:bookings_booking, :accepted, bookings_school: school).bookings_placement_request
    end

    let! :booked_but_not_accepted_placement_request do
      FactoryBot.create(:bookings_booking, bookings_school: school).bookings_placement_request
    end

    let! :placement_request_open do
      FactoryBot.create :placement_request, school: school
    end

    let! :booked_then_cancelled_by_candidate do
      FactoryBot
        .create(:bookings_booking, :accepted, :cancelled_by_candidate, bookings_school: school)
        .bookings_placement_request
    end

    describe '.unprocessed' do
      subject { described_class.unprocessed }

      it do
        expect(subject).to contain_exactly(placement_request_open, placement_request_cancelled_by_school_but_not_sent, booked_but_not_accepted_placement_request)
      end
    end

    describe '.unbooked' do
      subject { described_class.unbooked }

      it do
        expect(subject).to contain_exactly(placement_request_open, placement_request_cancelled_by_school_but_not_sent, placement_request_closed_by_candidate, placement_request_closed_by_school, booked_but_not_accepted_placement_request)
      end
    end

    describe '.cancelled' do
      subject { described_class.cancelled }

      it do
        expect(subject).to contain_exactly(placement_request_closed_by_candidate, placement_request_closed_by_school, booked_then_cancelled_by_candidate)
      end
    end

    describe '.not_cancelled' do
      subject { described_class.not_cancelled }

      it do
        expect(subject).to contain_exactly(placement_request_open, placement_request_cancelled_by_school_but_not_sent, booked_placement_request, booked_but_not_accepted_placement_request)
      end
    end

    describe '.withdrawn' do
      subject { described_class.withdrawn }

      let!(:unviewed) do
        travel_to 2.minutes.from_now do
          create :placement_request, :cancelled, school: school
        end
      end


      it { is_expected.to eq [unviewed, placement_request_closed_by_candidate] }
    end

    describe '.withdrawn_but_unviewed' do
      subject { described_class.withdrawn_but_unviewed }

      let!(:withdrawn_and_viewed) do
        create(:placement_request, :cancelled, school: school).tap do |pr|
          pr.candidate_cancellation.viewed!
        end
      end


      it { is_expected.to contain_exactly(placement_request_closed_by_candidate) }
    end

    describe '.rejected' do
      subject { described_class.rejected }

      let!(:unviewed) do
        travel_to 2.minutes.from_now do
          create :placement_request, :cancelled_by_school, school: school
        end
      end


      it { is_expected.to eq [unviewed, placement_request_closed_by_school] }
    end
  end

  context 'when complex scopes' do
    let :school do
      create :bookings_school, :with_subjects
    end

    let! :request_pending_decision do
      create :placement_request, school: school
    end

    let! :request_with_unviewed_candidate_cancellation do
      create :placement_request, :cancelled, school: school
    end

    let! :request_with_viewed_candidate_cancellation do
      create :placement_request,
        :with_viewed_candidate_cancellation, school: school
    end

    let! :request_with_booking do
      create :placement_request, :booked, school: school
    end

    let! :request_with_school_cancellation do
      create :placement_request, :cancelled_by_school, school: school
    end

    let! :other_schools_request do
      create :placement_request, school: create(:bookings_school, :with_subjects)
    end

    describe '.requiring_attention' do
      subject { school.placement_requests.requiring_attention }

      it { is_expected.to     include request_pending_decision }
      it { is_expected.to     include request_with_unviewed_candidate_cancellation }
      it { is_expected.not_to include request_with_viewed_candidate_cancellation }
      it { is_expected.not_to include request_with_booking }
      it { is_expected.not_to include request_with_school_cancellation }
      it { is_expected.not_to include other_schools_request }
    end
  end

  describe '.create_from_registration_session' do
    let(:candidate) { create(:candidate) }

    context 'when invalid session' do
      let :invalid_session do
        Candidates::Registrations::RegistrationSession.new \
          "candidates_registrations_background_check" => {},
          "candidates_registrations_contact_information" => {},
          "candidates_registrations_placement_preference" => {},
          "candidates_registrations_availability_preference" => {},
          "candidates_registrations_education" => {},
          "candidates_registrations_teaching_preference" => {},
          "urn" => 123_456
      end

      it 'raises a validation error' do
        expect {
          candidate.placement_requests.create_from_registration_session! \
            invalid_session
        }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context 'when valid session' do
      subject do
        candidate.placement_requests.create_from_registration_session! \
          registration_session
      end

      include_context 'with a stubbed candidate school'

      let :registration_session do
        FactoryBot.build :registration_session
      end


      it 'creates the placement request' do
        expect { subject }.to change(described_class, :count).by 1
      end

      it 'saves the experience type' do
        expect(subject.experience_type).not_to be_nil
      end
    end

    context 'when the school changes date type' do
      let! :candidate do
        create :candidate
      end

      context 'when from fixed to flex' do
        let! :school do
          create :bookings_school,
            :with_placement_dates,
            availability_preference_fixed: true
        end

        let! :registration_session do
          build :registration_session, :with_placement_date, urn: school.urn
        end

        before do
          school.update! availability_preference_fixed: false
        end

        it 'creates the placement_request' do
          expect {
            candidate
              .placement_requests
              .create_from_registration_session!(registration_session)
          }.to change { candidate.placement_requests.count }.by 1
        end
      end

      context 'when from flex to fixed' do
        let! :school do
          create :bookings_school, availability_preference_fixed: false
        end

        let! :registration_session do
          build :registration_session, :with_flexible_dates, urn: school.urn
        end

        before do
          school.update! availability_preference_fixed: true
        end

        it 'creates the placement_request' do
          expect {
            candidate
              .placement_requests
              .create_from_registration_session!(registration_session)
          }.to change { candidate.placement_requests.count }.by 1
        end
      end
    end

    context 'when subject_specific_date' do
      let! :candidate do
        create :candidate
      end

      let! :bookings_subject_1 do
        create :bookings_subject
      end

      let! :bookings_subject_2 do
        create :bookings_subject
      end

      let! :school do
        create :bookings_school,
          availability_preference_fixed: true,
          subjects: [bookings_subject_1, bookings_subject_2]
      end

      let! :placement_preference do
        build :placement_preference
      end

      let! :availability_preference do
        build :availability_preference
      end

      let! :teaching_preference do
        build :teaching_preference, school: school,
                                    subject_first_choice: school.subjects.first.name,
                                    subject_second_choice: school.subjects.second.name
      end

      let! :registration_session do
        build(:registration_session, urn: school.urn).tap do |rs|
          # Overwrite the default factory steps
          # So we have a registration for a fixed date school with subjects.
          rs.save subject_and_date_information
          rs.save placement_preference
          rs.save availability_preference
          rs.save teaching_preference
        end
      end

      context 'when the school makes the applied for subject unavailable' do
        let! :placement_date do
          create :bookings_placement_date,
            bookings_school: school,
            subject_specific: true,
            subjects: [bookings_subject_1]
        end

        let! :subject_and_date_information do
          build :subject_and_date_information,
            bookings_placement_date_id: placement_date.id,
            bookings_subject_id: placement_date.placement_date_subjects.first.bookings_subject.id
        end

        before do
          placement_date.update! subjects: [bookings_subject_2]
        end

        it 'creates the placement_request' do
          expect {
            candidate
              .placement_requests
              .create_from_registration_session!(registration_session)
          }.to change { candidate.placement_requests.count }.by 1
        end
      end

      context 'when the school makes the applied for date subject_specific' do
        let! :placement_date do
          create :bookings_placement_date,
            bookings_school: school,
            subject_specific: false
        end

        let! :subject_and_date_information do
          build :subject_and_date_information,
            bookings_placement_date_id: placement_date.id
        end

        before do
          placement_date.update! \
            subject_specific: true, subjects: [bookings_subject_1]
        end

        it 'creates the placement_request' do
          expect {
            candidate
              .placement_requests
              .create_from_registration_session!(registration_session)
          }.to change { candidate.placement_requests.count }.by 1
        end
      end
    end
  end

  context 'with attributes' do
    it { is_expected.to respond_to :gitis_contact }
    it { is_expected.to respond_to :urn }
    it { is_expected.to respond_to :degree_stage }
    it { is_expected.to respond_to :degree_stage_explaination }
    it { is_expected.to respond_to :degree_subject }
    it { is_expected.to respond_to :teaching_stage }
    it { is_expected.to respond_to :subject_first_choice }
    it { is_expected.to respond_to :subject_second_choice }
    it { is_expected.to respond_to :availability }
    it { is_expected.to respond_to :objectives }
    it { is_expected.to respond_to :bookings_placement_date_id }
  end

  context 'when validating' do
    it { is_expected.to validate_presence_of :urn }

    it { is_expected.to validate_presence_of :degree_stage }

    it do
      expect(subject).to validate_inclusion_of(:degree_stage).in_array \
        described_class::OPTIONS_CONFIG.fetch 'DEGREE_STAGES'
    end

    context 'when degree stage is "Other"' do
      before do
        allow(subject).to receive(:degree_stage).and_return("Other")
      end

      it { is_expected.to validate_presence_of :degree_stage_explaination }
    end

    context 'when degree stage is not "Other"' do
      it { is_expected.not_to validate_presence_of :degree_stage_explaination }
    end

    it { is_expected.to validate_presence_of :degree_subject }

    context 'when degree stage is "I don\'t have a degree and am not studying for one"' do
      before do
        allow(subject).to receive(:degree_stage).and_return("I don't have a degree and am not studying for one")
      end

      it do
        expect(subject).to validate_absence_of(:degree_subject)
      end
    end

    context 'when degree stage is not "I don\'t have a degree and am not studying for one"' do
      before do
        allow(subject).to receive(:degree_stage).and_return('Final year')
      end

      it do
        expect(subject).to validate_presence_of(:degree_subject)
      end
    end

    it { is_expected.to validate_presence_of :teaching_stage }

    it do
      expect(subject).to validate_inclusion_of(:teaching_stage).in_array \
        described_class::OPTIONS_CONFIG.fetch('TEACHING_STAGES')
    end

    it { is_expected.to validate_presence_of :subject_first_choice }

    it do
      expect(subject).to validate_inclusion_of(:subject_first_choice).in_array \
        allowed_subject_choices
    end

    it { is_expected.to validate_presence_of :subject_second_choice }

    it do
      expect(subject).to validate_inclusion_of(:subject_second_choice).in_array \
        second_subject_choices
    end
  end

  describe '#available_subject_choices' do
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

  describe '#second_subject_choices' do
    it "returns the list of subjects from it's school" do
      choices = subject.second_subject_choices
      no_choice = choices.shift

      expect(choices).to \
        eq subject.available_subject_choices

      expect(no_choice).to match(/don't have/)
    end
  end

  describe '#requires_subject_for_degree_stage?' do
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


  context 'when validations for placement preferences' do
    before do
      placement_request.validate
    end

    context 'when the school mandates fixed dates' do
      before do
        allow(placement_request).to receive(:school_offers_fixed_dates?).and_return(true)
placement_request.validate
      end

      let(:placement_request) { described_class.new(bookings_school_id: school.id) }


      it 'adds an error to bookings_placement_date_id' do
        expect(placement_request.errors[:bookings_placement_date_id]).to include \
          "Choose a placement date"
      end
    end

    context 'when objectives are not present' do
      let :placement_request do
        described_class.new
      end

      it 'adds an error to objectives' do
        expect(placement_request.errors[:objectives]).to eq \
          ["Enter what you want to get out of your placement"]
      end
    end

    context 'when objectives are too long' do
      let :placement_request do
        described_class.new \
          objectives: 151.times.map { 'word' }.join(' ')
      end

      it 'adds an error to objectives' do
        expect(placement_request.errors[:objectives]).to eq \
          ["Use 150 words or fewer"]
      end
    end
  end

  context 'when validations for availability preference' do
    before do
      placement_request.validate
    end

    let! :school do
      create :bookings_school,
        availability_preference_fixed: false
    end

    context 'when the school allows flexible dates' do
      let(:placement_request) { described_class.new(bookings_school_id: school.id) }

      context 'when availability is not present' do
        it 'adds an error to availability' do
          expect(placement_request.errors[:availability]).to eq \
            ["Enter your availability"]
        end
      end

      context 'when availability is too long' do
        let :placement_request do
          described_class.new \
            availability: 151.times.map { 'word' }.join(' ')
        end

        it 'adds an error to availability' do
          expect(placement_request.errors[:availability]).to eq \
            ["Use 150 words or fewer"]
        end
      end
    end
  end

  describe '#closed?' do
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

  context 'when build_candidate_cancellation' do
    let :cancellation do
      described_class.new.build_candidate_cancellation
    end

    it 'returns a new cancellation with cancelled_by set to "candidate"' do
      expect(cancellation.cancelled_by).to eq 'candidate'
    end
  end

  context 'when build_school_cancellation' do
    let :cancellation do
      described_class.new.build_school_cancellation
    end

    it 'returns a new cancellation with cancelled_by set to "school"' do
      expect(cancellation.cancelled_by).to eq 'school'
    end
  end

  describe '#cancellation' do
    context 'when cancelled by candidate' do
      subject { create(:placement_request, :cancelled) }

      it 'returns the candidate_cancellation' do
        expect(subject.cancellation).not_to be_nil
        expect(subject.cancellation).to eq subject.candidate_cancellation
      end
    end

    context 'when cancelled by school' do
      subject { create(:placement_request, :cancelled_by_school) }

      it 'returns the school_cancellation' do
        expect(subject.cancellation).not_to be_nil
        expect(subject.cancellation).to eq subject.school_cancellation
      end
    end

    context 'when not cancelled' do
      subject { described_class.new }

      it 'returns nil' do
        expect(subject.cancellation).to be_nil
      end
    end
  end

  describe '#status' do
    context 'with default' do
      subject { create(:placement_request).status }

      it { is_expected.to eq 'New' }
    end

    context 'when cancelled by candidate' do
      subject { create(:placement_request, :cancelled).status }

      it { is_expected.to eq 'Withdrawn' }
    end

    context 'when cancelled by school' do
      subject { create(:placement_request, :cancelled_by_school).status }

      it { is_expected.to eq 'Rejected' }
    end

    context 'when viewed' do
      subject { create(:placement_request, :viewed).status }

      it { is_expected.to eq 'Viewed' }
    end

    context 'when under consideration' do
      subject { create(:placement_request, :under_consideration).status }

      it { is_expected.to eq 'Under consideration' }
    end

    context 'with incomplete booking' do
      subject { create(:placement_request, :with_incomplete_booking).status }

      it { is_expected.to eq 'New' }
    end

    context 'when booked' do
      subject { create(:placement_request, :booked).status }

      it { is_expected.to eq 'Booked' }
    end

    context 'when booked and cancelled by candidate' do
      subject { create(:placement_request, :booked, :cancelled).status }

      it { is_expected.to eq 'Candidate cancellation' }
    end

    context 'when booked and cancelled by school' do
      subject { create(:placement_request, :booked, :cancelled_by_school).status }

      it { is_expected.to eq 'School cancellation' }
    end

    context 'when candidate has attended previous school experiences' do
      subject { create(:placement_request, :with_attended_booking).status }

      it { is_expected.to eq 'Flagged' }
    end

    context 'when expired request' do
      context 'when fixed placement request' do
        it 'returns Expired when the placement date has lapsed' do
          request = create(:placement_request, :with_a_fixed_date)

          travel 1.year do
            expect(request.status).to eq 'Expired'
          end
        end

        it 'does not returns Expired when the placement date has not lapsed' do
          request = create(:placement_request, :with_a_fixed_date)

          expect(request.status).not_to eq 'Expired'
        end
      end

      context 'when flex placement request' do
        it 'returns Expired when it is older than two months' do
          request = create(:placement_request)

          travel 3.months do
            expect(request.status).to eq 'Expired'
          end
        end

        it 'does not returns Expired when it is not older than two months' do
          request = create(:placement_request)

          travel(2.months - 1.day) do
            expect(request.status).not_to eq 'Expired'
          end
        end
      end
    end
  end

  describe '#dbs' do
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

  describe '#viewed_at' do
    subject { FactoryBot.create :placement_request }

    specify 'should be nil' do
      expect(subject.viewed_at).to be_nil
    end
  end

  describe '#under_consideration?' do
    context 'when under_consideration_at has a date' do
      subject { under_consideration_placement_request.under_consideration_at? }

      let(:under_consideration_placement_request) { create(:placement_request, :under_consideration) }


      it { is_expected.to be(true) }
    end

    context 'when under_consideration_at is null' do
      subject { placement_request.under_consideration_at? }

      let(:placement_request) { create(:placement_request) }


      it { is_expected.to be(false) }
    end
  end

  describe '#viewed!' do
    subject { FactoryBot.create :placement_request }

    context 'when #viewed_at has not already been set' do
      before { subject.viewed! }

      specify 'should set #viewed_at to now' do
        expect(subject.viewed_at).to be_within(0.1).of(Time.zone.now)
      end
    end

    context 'when #viewed_at has already been set' do
      subject { FactoryBot.create(:placement_request, viewed_at: ts) }

      let(:ts) { 3.weeks.ago }


      before { subject.viewed! }

      specify 'should not overwrite #viewed_at' do
        expect(subject.viewed_at).to eql(ts)
      end
    end
  end

  describe '#requested_on' do
    subject { create :placement_request }

    it { is_expected.to have_attributes(requested_on: subject.created_at.to_date) }
  end

  describe '#requested_subject' do
    subject { placement_request.requested_subject }

    let :subject_1 do
      create :bookings_subject
    end

    let :subject_2 do
      create :bookings_subject
    end

    let :school do
      create :bookings_school, subjects: [subject_1, subject_2]
    end

    let :placement_request do
      create :placement_request, school: school
    end


    context 'when the date is not subject-specific' do
      it { is_expected.to eq subject_1 }
    end

    context 'when the date is subject-specific' do
      before { placement_request.subject = subject_2 }

      it { is_expected.to eq subject_2 }
    end
  end

  describe '#fixed_date' do
    subject { pr.fixed_date }

    context 'with fixed date' do
      let(:pr) { build :placement_request, :with_a_fixed_date }

      it { is_expected.to eql pr.placement_date.date }
    end

    context 'with flexible date' do
      let(:pr) { build :placement_request }

      it { is_expected.to be_nil }
    end
  end

  describe '#fixed_date_is_bookable?' do
    subject { pr.fixed_date_is_bookable? }

    let(:pr) { build :placement_request, :with_a_fixed_date }
    let(:date) { pr.placement_date }


    context 'when the date is today' do
      before { date.date = Time.zone.today }

      it { is_expected.to be false }
    end

    context 'when the date is yesterday' do
      before { date.date = Time.zone.yesterday }

      it { is_expected.to be false }
    end

    context 'when the date is tomorrow' do
      before { date.date = Time.zone.tomorrow }

      it { is_expected.to be true }
    end

    context 'with flexible' do
      let(:pr) { build(:placement_request) }

      it { is_expected.to be false }
    end
  end

  describe '#resolve_experience_type' do
    context 'when it is a flex date' do
      it 'returns the experience type of the school' do
        expect(subject.resolve_experience_type).to eq subject.school.experience_type
      end
    end

    context 'when it is a fixed date' do
      subject { build :placement_request, :with_a_fixed_date }

      it 'returns the experience type of the placement date' do
        expect(subject.resolve_experience_type).to eq subject.placement_date.experience_type
      end
    end
  end

  describe '#flex_date?' do
    context 'without a placement date' do
      it "returns true" do
        expect(subject.flex_date?).to be true
      end
    end

    context 'with a placement date' do
      subject { build :placement_request, :with_a_fixed_date }

      it "returns false" do
        expect(subject.flex_date?).to be false
      end
    end
  end

  describe '#unclear_experience_type?' do
    context 'when it is a flex date' do
      context 'when experience is virtual' do
        subject { build :placement_request, :virtual, school: school }

        let(:school) { build :bookings_school, :flex_virtual }


        it 'returns false' do
          expect(subject.unclear_experience_type?).to be false
        end
      end

      context 'when experience is in school' do
        subject { build :placement_request, :inschool, school: school }

        let(:school) { build :bookings_school, :flex_inschool }


        it 'returns false' do
          expect(subject.unclear_experience_type?).to be false
        end
      end

      context 'when the experience is both' do
        subject { build :placement_request, school: school }

        let(:school) { build :bookings_school, :flex_both }


        it 'returns true' do
          expect(subject.unclear_experience_type?).to be true
        end
      end

      context 'when the school and placement request experience types are different' do
        subject { build :placement_request, :virtual, school: school }

        let(:school) { build :bookings_school, :flex_both }


        it 'returns true' do
          expect(subject.unclear_experience_type?).to be true
        end
      end
    end

    context 'when it is a fixed date' do
      subject { build :placement_request, :with_a_fixed_date }

      it 'returns false' do
        expect(subject.unclear_experience_type?).to be false
      end
    end
  end
end
