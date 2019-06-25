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
    it { is_expected.to have_many :placement_requests }
    it { is_expected.to have_many :bookings }
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
end
