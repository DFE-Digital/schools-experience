require 'rails_helper'

RSpec.describe Candidates::SessionToken, type: :model do
  let(:session_token) { create(:candidate_session_token) }

  describe 'database structure' do
    it { is_expected.to have_db_column(:token).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_index(:token).unique }
  end

  describe 'associations' do
    it { is_expected.to belong_to :candidate }
  end

  describe '.unexpired' do
    let!(:valid) { create(:candidate_session_token) }
    let!(:expired) { create(:candidate_session_token, expired_at: 5.minutes.ago) }

    subject { described_class.unexpired.to_a }

    it "should only return the valid token" do
      is_expected.to eq([valid])
    end
  end

  describe '.valid' do
    let!(:valid) { create(:candidate_session_token) }
    let!(:expired) { create(:candidate_session_token, expired_at: 5.minutes.ago) }
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
        expect(token.expired_at).to be > 1.minutes.ago
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
end
