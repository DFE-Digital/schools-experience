require 'rails_helper'

RSpec.describe Candidates::SessionToken, type: :model do
  let(:session_token) { create(:candidate_session_token) }

  describe 'database structure' do
    it { is_expected.to have_db_column(:token).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_index(:token).unique }
    it { is_expected.to have_secure_token }
  end

  describe 'associations' do
    it { is_expected.to belong_to :candidate }
  end

  describe 'confirmation scopes' do
    let!(:unconfirmed) { create(:candidate_session_token) }
    let!(:confirmed) { create(:candidate_session_token, :confirmed) }

    describe '.unconfirmed' do
      subject { described_class.unconfirmed.to_a }

      it "should only return confirmed token" do
        is_expected.to eq([unconfirmed])
      end
    end

    describe '.confirmed' do
      subject { described_class.confirmed.to_a }

      it "should only return confirmed token" do
        is_expected.to eq([confirmed])
      end
    end
  end

  describe '.unexpired' do
    let!(:valid) { create(:candidate_session_token) }
    let!(:expired) { create(:candidate_session_token, :expired) }

    subject { described_class.unexpired.to_a }

    it "should only return the valid token" do
      is_expected.to eq([valid])
    end
  end

  describe '.valid' do
    let!(:valid) { create(:candidate_session_token) }
    let!(:expired) { create(:candidate_session_token, :expired) }
    let!(:first) { create(:candidate_session_token, created_at: 10.days.ago) }

    subject { described_class.valid.to_a }

    it "should only return the valid token" do
      is_expected.to eq([valid])
    end
  end

  describe '.create' do
    let(:candidate) { create(:candidate) }
    subject { candidate.session_tokens.create }
    it { is_expected.to be_persisted }
    it { is_expected.to have_attribute(:token) }
  end

  describe '.remove_old!' do
    subject do
      described_class.remove_old!
      described_class.find_by(id: token.id)
    end

    context 'with old token' do
      let!(:token) { create(:candidate_session_token, created_at: 8.days.ago) }
      it { is_expected.to be_nil }
    end

    context 'with new token' do
      let!(:token) { create(:candidate_session_token, created_at: 1.day.ago) }
      it { is_expected.to eql token }
    end
  end

  describe '#expired?' do
    context 'with valid' do
      subject { build(:candidate_session_token) }
      it("is not expired") { is_expected.not_to be_expired }
    end

    context 'with flagged expired' do
      subject { build(:candidate_session_token, :expired) }
      it("is expired") { is_expected.to be_expired }
    end

    context 'with too old' do
      subject { build(:candidate_session_token, :auto_expired) }
      it("is expired") { is_expected.to be_expired }
    end
  end

  describe '#expire!' do
    context 'with already expired' do
      let(:token) { build(:candidate_session_token, expired_at: 10.days.ago) }
      before { token.expire! }

      it("will be expired now") do
        expect(token.expired_at).to be < 9.days.ago
      end
    end

    context 'with unexpired' do
      let(:token) { build(:candidate_session_token) }
      before { token.expire! }

      it("will be expired now") do
        expect(token.expired_at).to be > 1.minute.ago
      end
    end
  end

  describe '.expire_all!' do
    let!(:first) { create(:candidate_session_token) }
    let!(:second) { create(:candidate_session_token, candidate: first.candidate) }
    let!(:third) { create(:candidate_session_token, :expired, candidate: first.candidate) }

    before { described_class.expire_all! }

    it 'will invalidate other login tokens from same candidate' do
      expect(second.reload.expired?).to be true
    end

    it 'will not expire already expired tokens' do
      expect(third.reload.expired_at).to be < 3.minutes.ago
    end
  end

  describe 'confirm!' do
    let!(:first) { create(:candidate_session_token) }
    let!(:second) { create(:candidate_session_token, candidate: first.candidate) }
    let!(:third) { create(:candidate_session_token) }

    before { first.confirm! }

    it "will confirm current_token" do
      expect(first.reload).to be_confirmed
      expect(first).not_to be_expired
    end

    it "will expire other tokens for same candidate" do
      expect(second.reload).to be_expired
      expect(second).not_to be_confirmed
    end

    it "will not affect other candidates tokens" do
      expect(third.reload).not_to be_expired
      expect(third.reload).not_to be_confirmed
    end

    it "will confirm the candidate" do
      expect(first.candidate.reload).to be_confirmed
    end
  end
end
