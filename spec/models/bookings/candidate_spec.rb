require 'rails_helper'

RSpec.describe Bookings::Candidate, type: :model do
  describe 'database structure' do
    it { is_expected.to have_db_column(:gitis_uuid).of_type(:string).with_options(limit: 36) }
    it { is_expected.to have_db_index(:gitis_uuid).unique }
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

  describe '.generate_session_token!' do
    let(:candidate) { create(:candidate) }

    it "should create a new token" do
      expect(candidate.generate_session_token!).to be_kind_of(Candidates::SessionToken)
      expect(candidate.session_tokens.count).to eql(1)
    end
  end

  describe '.expire_session_tokens!' do
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

  describe '.last_signed_in_at' do
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
end
