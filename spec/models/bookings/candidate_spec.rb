require 'rails_helper'

RSpec.describe Bookings::Candidate, type: :model do
  include_context "api teaching subjects"

  describe 'database structure' do
    it { is_expected.to have_db_column(:gitis_uuid).of_type(:uuid) }
    it { is_expected.to have_db_index(:gitis_uuid).unique }
  end

  describe 'attributes' do
    it { is_expected.to respond_to :contact_uuid }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :gitis_uuid }

    it { is_expected.to allow_value(SecureRandom.uuid).for :gitis_uuid }
    it { is_expected.not_to allow_value(nil).for :gitis_uuid }
    it { is_expected.not_to allow_value('').for :gitis_uuid }
    it { is_expected.not_to allow_value('foobar').for :gitis_uuid }

    it do
      is_expected.not_to \
        allow_value(SecureRandom.uuid + SecureRandom.uuid).for :gitis_uuid
    end

    context 'with existing record' do
      before { create(:candidate) }
      it { is_expected.to validate_uniqueness_of(:gitis_uuid).case_insensitive }
    end
  end

  describe 'associations' do
    it { is_expected.to have_many :session_tokens }
    it { is_expected.to have_many(:placement_requests).inverse_of :candidate }
    it { is_expected.to have_many :bookings }
    it { is_expected.to have_many(:events).inverse_of :bookings_candidate }
  end

  describe 'scopes' do
    context 'for confirmations' do
      let!(:confirmed) { create(:candidate, :confirmed) }
      let!(:unconfirmed) { create(:candidate) }

      describe '.confirmed' do
        subject { described_class.confirmed.to_a }

        it "will only include confirmed" do
          is_expected.to eql([confirmed])
        end
      end

      describe '.unconfirmed' do
        subject { described_class.unconfirmed.to_a }

        it "will only include unconfirmed" do
          is_expected.to eql([unconfirmed])
        end
      end
    end
  end

  describe '.find_by_gitis_contact' do
    let(:gitis_contact) { build(:api_schools_experience_sign_up_with_name) }

    context 'with existing Candidate' do
      let!(:candidate) { create(:candidate, gitis_uuid: gitis_contact.candidate_id) }
      subject { Bookings::Candidate.find_by_gitis_contact gitis_contact }

      it "return existing candidate" do
        is_expected.to eql candidate
      end

      it "will assign gitis_contact" do
        is_expected.to have_attributes(gitis_contact: gitis_contact)
      end
    end

    context 'without existing Candidate' do
      subject { Bookings::Candidate.find_by_gitis_contact gitis_contact }
      it { is_expected.to be_nil }
    end
  end

  describe '.find_by_gitis_contact!' do
    let(:gitis_contact) { build(:api_schools_experience_sign_up_with_name) }

    context 'with existing Candidate' do
      let!(:candidate) { create(:candidate, gitis_uuid: gitis_contact.candidate_id) }
      subject { Bookings::Candidate.find_by_gitis_contact! gitis_contact }

      it "return existing candidate" do
        is_expected.to eql candidate
      end

      it "will assign gitis_contact" do
        is_expected.to have_attributes(gitis_contact: gitis_contact)
      end
    end

    context 'without existing Candidate' do
      it "raise record not found" do
        expect {
          Bookings::Candidate.find_by_gitis_contact! gitis_contact
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '.find_or_create_from_gitis_contact!' do
    let(:gitis_contact) { build(:api_schools_experience_sign_up_with_name) }

    subject do
      Bookings::Candidate.find_or_create_from_gitis_contact! gitis_contact
    end

    context 'with existing' do
      let!(:candidate) { create(:candidate, gitis_uuid: gitis_contact.candidate_id) }

      it "return existing candidate" do
        is_expected.to eql candidate
      end

      it "will assign gitis_contact" do
        is_expected.to have_attributes(gitis_contact: gitis_contact)
      end
    end

    context 'without existing' do
      it "will create candidate" do
        is_expected.to be_kind_of Bookings::Candidate
        is_expected.to be_persisted
      end

      it "will assign gitis_contact" do
        is_expected.to have_attributes(gitis_contact: gitis_contact)
      end
    end
  end

  describe '.create_from_registration_session!' do
    include_context "api latest privacy policy"

    let(:registration) { build(:registration_session, :with_school) }

    subject do
      described_class.create_from_registration_session! registration
    end

    before do
      allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
        receive(:sign_up_schools_experience_candidate) do |_, sign_up|
          sign_up.candidate_id = SecureRandom.uuid
          sign_up
        end
    end

    it { is_expected.to be_kind_of Bookings::Candidate }
    it { is_expected.to be_persisted }
    it { is_expected.to have_attributes(gitis_uuid: subject.gitis_contact.candidate_id) }
    it { is_expected.to have_attributes(gitis_contact: instance_of(GetIntoTeachingApiClient::SchoolsExperienceSignUp)) }

    it "will assign contact attributes" do
      expect(subject.gitis_contact).to have_attributes \
        first_name: registration.personal_information.first_name,
        last_name: registration.personal_information.last_name
    end
  end

  describe '.create_or_update_from_registration_session!' do
    let(:registration_session) { build(:registration_session, :with_school) }

    context 'with an existing contact and existing candidate' do
      let(:candidate) { create(:candidate, :with_api_contact) }
      let(:contact) { candidate.gitis_contact }

      subject do
        Bookings::Candidate.create_or_update_from_registration_session! \
          registration_session, contact
      end

      it "will return the existing candidate" do
        is_expected.to eql candidate
      end

      it "will update the contacts details" do
        expect(subject.gitis_contact).to have_attributes \
          first_name: registration_session.personal_information.first_name,
          last_name: registration_session.personal_information.last_name
      end

      it "will mark as already existing in gitis" do
        is_expected.to have_attributes(created_in_gitis: false)
      end
    end

    context 'with an existing contact but not candidate' do
      let(:contact) { build(:api_schools_experience_sign_up_with_name) }

      subject do
        Bookings::Candidate.create_or_update_from_registration_session! \
          registration_session, contact
      end

      it "will create a Candidate" do
        is_expected.to be_kind_of Bookings::Candidate
        is_expected.to be_persisted
      end

      it "will update the contacts details" do
        expect(subject.gitis_contact).to have_attributes \
          first_name: registration_session.personal_information.first_name,
          last_name: registration_session.personal_information.last_name
      end

      it "will mark as already existing in gitis" do
        is_expected.to have_attributes(created_in_gitis: false)
      end
    end

    context 'with no contact or candidate' do
      let(:contact_id) { SecureRandom.uuid }

      subject do
        Bookings::Candidate.create_or_update_from_registration_session! \
          registration_session, nil
      end

      it "will create a Candidate" do
        is_expected.to be_kind_of Bookings::Candidate
        is_expected.to be_persisted
      end

      it "will create the Contacts with registration details" do
        expect(subject.gitis_contact).to have_attributes \
          first_name: registration_session.personal_information.first_name,
          last_name: registration_session.personal_information.last_name
      end

      it "will mark as newly created in gitis" do
        is_expected.to have_attributes(created_in_gitis: true)
      end
    end
  end

  describe '#update_from_registration_session!' do
    include_context "api latest privacy policy"
    include_context "api sign up"

    let(:registration) { build(:registration_session, :with_school) }
    let(:candidate) { build(:candidate, :with_api_contact) }

    subject do
      candidate.update_from_registration_session! registration
    end

    it { is_expected.to be_kind_of Bookings::Candidate }
    it { is_expected.to have_attributes(gitis_uuid: subject.gitis_contact.candidate_id) }
    it { is_expected.to have_attributes(gitis_contact: instance_of(GetIntoTeachingApiClient::SchoolsExperienceSignUp)) }

    it "will assign contact attributes" do
      expect(subject.gitis_contact).to have_attributes \
        first_name: registration.personal_information.first_name,
        last_name: registration.personal_information.last_name
    end
  end

  describe '#assign_gitis_contact' do
    let(:contact) { build(:api_schools_experience_sign_up_with_name) }
    let(:candidate) { create(:candidate) }
    let(:candidate_uuid) { candidate.gitis_uuid }
    before { candidate.assign_gitis_contact contact }
    subject { candidate.reload }

    it 'should update the gitis contact' do
      expect(candidate).to have_attributes gitis_contact: contact
    end
    it 'should not update the gitis UUID' do
      expect(candidate).to have_attributes gitis_uuid: candidate_uuid
    end
  end

  describe '#generate_session_token!' do
    let(:candidate) { create(:candidate) }

    it "should create a new token" do
      expect(candidate.generate_session_token!).to be_kind_of(Candidates::SessionToken)
      expect(candidate.session_tokens.count).to eql(1)
    end
  end

  describe '#expire_session_tokens!' do
    let!(:first) { create(:candidate_session_token) }
    let!(:second) { create(:candidate_session_token, candidate: first.candidate) }
    let!(:third) { create(:candidate_session_token, :expired, candidate: first.candidate) }
    let!(:another) { create(:candidate_session_token) }

    before { first.candidate.expire_session_tokens! }

    it 'will invalidate other login tokens from same candidate' do
      expect(second.reload.expired?).to be true
    end

    it 'will not expire already expired tokens' do
      expect(third.reload.expired_at).to be < 3.minutes.ago
    end

    it "will not expire other candidates tokens" do
      expect(another.reload.expired?).to be false
    end
  end

  describe '#last_signed_in_at' do
    let!(:first) { create(:candidate_session_token, :confirmed) }

    let!(:second) do
      create(:candidate_session_token, candidate: first.candidate).tap(&:confirm!)
    end

    context 'for confirmed candidate' do
      it "will return last confirmed token timestamp" do
        expect(first.candidate.last_signed_in_at.to_i).to eql(second.confirmed_at.to_i)
      end
    end

    context 'for subsequently deconfirmed candidate' do
      before { first.candidate.update!(confirmed_at: nil) }

      it "will return last confirmed token timestamp" do
        expect(first.candidate.last_signed_in_at.to_i).to eql(second.confirmed_at.to_i)
      end
    end
  end

  describe "contact accessor attributes" do
    subject { build :candidate, :with_api_contact }
    it "will be delegated to gitis contact" do
      full_name = "#{subject.gitis_contact.first_name} #{subject.gitis_contact.last_name}"

      is_expected.to have_attributes \
        full_name: full_name,
        email: subject.gitis_contact.email
    end
  end

  describe '#attended_bookings' do
    context 'when attended bookings exist' do
      subject { create(:recurring_candidate).attended_bookings }

      it { is_expected.to all(be_a Bookings::Booking) }

      it 'returns attended bookings only' do
        subject.each do |booking|
          expect(booking.attended).to be_truthy
        end
      end
    end

    context 'when there are no attended bookings' do
      subject { create(:candidate).attended_bookings }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end
  end

  describe "#orphaned?" do
    subject { build(:candidate) }

    it { is_expected.not_to be_orphaned }

    context "when an gitis_contact is set" do
      subject { build(:candidate, :with_api_contact) }

      it { is_expected.not_to be_orphaned }
    end

    context "when the gitis_contact is missing" do
      subject { build(:candidate, :with_missing_api_contact) }

      it { is_expected.to be_orphaned }
    end
  end
end
