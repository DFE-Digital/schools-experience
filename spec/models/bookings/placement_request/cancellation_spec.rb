require 'rails_helper'

describe Bookings::PlacementRequest::Cancellation, type: :model do
  it { is_expected.to belong_to :placement_request }
  it { is_expected.to have_db_column(:reason).of_type(:text).with_options null: true }
  it { is_expected.to have_db_column(:extra_details).of_type(:text) }
  it { is_expected.to validate_presence_of :reason }
  it { is_expected.not_to validate_presence_of :extra_details }
  it { is_expected.to validate_inclusion_of(:cancelled_by).in_array %w(candidate school) }

  describe 'scopes' do
    describe '#sent' do
      let!(:cancellation) { create :cancellation }
      subject { described_class.sent.to_a }

      it { is_expected.not_to include cancellation }

      context 'when sent' do
        before { cancellation.sent! }
        it { is_expected.to include cancellation }
      end
    end
  end

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

    context 'when already sent' do
      subject { FactoryBot.create(:cancellation, sent_at: 5.minutes.ago) }

      it "does not update" do
        expect(subject).to be_sent
        expect(subject.sent_at).to be < 1.minute.ago
      end
    end
  end

  describe '#dates_requested' do
    let(:placement_request) { create(:placement_request, :cancelled_by_school) }
    subject { placement_request.school_cancellation }

    context 'when the placement has been accepted' do
      let!(:booking) { create(:bookings_booking, bookings_placement_request: placement_request) }

      specify "should be the booking's date" do
        expect(subject.dates_requested).to eql(booking.date.to_formatted_s(:govuk))
      end
    end

    context "when the placement not has been accepted" do
      specify 'should be the placement request availability' do
        expect(subject.dates_requested).to eql(placement_request.dates_requested)
      end
    end
  end
end
