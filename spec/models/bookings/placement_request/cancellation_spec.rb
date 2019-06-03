require 'rails_helper'

describe Bookings::PlacementRequest::Cancellation, type: :model do
  it { is_expected.to belong_to :placement_request }
  it { is_expected.to have_db_column(:reason).of_type(:text).with_options null: false }
  it { is_expected.to validate_presence_of :reason }
  it { is_expected.to validate_inclusion_of(:cancelled_by).in_array %w(candidate school) }

  context 'when placement_request is already closed' do
    let :placement_request do
      FactoryBot.create :placement_request, :cancelled
    end

    subject { described_class.new placement_request: placement_request }

    before do
      subject.validate
    end

    it 'is invalid' do
      expect(subject.errors[:placement_request]).to eq ['is already closed']
    end
  end

  context '#sent!' do
    subject { FactoryBot.create :cancellation }

    before do
      subject.sent!
    end

    it 'marks the cancellation as sent' do
      expect(subject).to be_sent
      expect(subject.sent_at).to be_present
    end

    it 'closes the placement request' do
      expect(subject.reload.placement_request).to be_closed
    end
  end
end
