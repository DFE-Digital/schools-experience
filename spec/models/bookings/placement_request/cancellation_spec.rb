require 'rails_helper'

describe Bookings::PlacementRequest::Cancellation, type: :model do
  it { is_expected.to belong_to :placement_request }
  it { is_expected.to have_db_column(:reason).of_type(:text).with_options null: true }
  it { is_expected.to have_db_column(:extra_details).of_type(:text) }
  it { is_expected.to have_db_column(:fully_booked).of_type(:boolean) }
  it { is_expected.to have_db_column(:date_not_available).of_type(:boolean) }
  it { is_expected.to have_db_column(:accepted_on_ttc).of_type(:boolean) }
  it { is_expected.to have_db_column(:no_relevant_degree).of_type(:boolean) }
  it { is_expected.to have_db_column(:no_phase_availability).of_type(:boolean) }
  it { is_expected.to have_db_column(:candidate_not_local).of_type(:boolean) }
  it { is_expected.to have_db_column(:duplicate).of_type(:boolean) }
  it { is_expected.to have_db_column(:info_not_provided).of_type(:boolean) }
  it { is_expected.to have_db_column(:wrong_choice_primary).of_type(:boolean) }
  it { is_expected.to have_db_column(:cancelation_requested).of_type(:boolean) }
  it { is_expected.to have_db_column(:wrong_choice_secondary).of_type(:boolean) }
  it { is_expected.to have_db_column(:other).of_type(:boolean) }

  describe 'Validation' do
    it { is_expected.not_to validate_presence_of :extra_details }
    it { is_expected.to validate_inclusion_of(:cancelled_by).in_array %w[candidate school] }
    it { is_expected.to validate_presence_of(:reason).on(%i[school_cancellation candidate_cancellation]) }
    it { is_expected.not_to validate_presence_of(:reason) }

    context "when 'other' is specififed" do
      let(:cancellation) { build(:cancellation, other: true) }

      it { expect(cancellation).to validate_presence_of(:reason).on(%i[rejection]) }
    end

    describe "rejection" do
      let(:cancellation) { build(:cancellation) }

      before { cancellation.save(context: :rejection) }

      subject { cancellation.errors.messages }

      it { is_expected.to include(base: ["Chooose a reason for rejecting this candidate"]) }

      context "when there are rejection categories specified" do
        let(:cancellation) { build(:cancellation, fully_booked: true) }

        it { is_expected.to be_empty }
      end
    end
  end

  describe "before save" do
    let(:cancellation) { build(:cancellation, reason: "Other reason.") }

    it { expect { cancellation.save }.not_to change(cancellation, :rejection_category) }

    context "when a rejection category was changed" do
      let(:cancellation) { build(:cancellation, fully_booked: true) }

      it { expect { cancellation.save }.to change(cancellation, :rejection_category).to("fully_booked") }
    end

    context "when multiple rejection categories are changed" do
      let(:cancellation) { build(:cancellation, duplicate: true, wrong_choice_secondary: true) }

      it "sets the rejection_category to the first category that is true" do
        expect { cancellation.save }.to change(cancellation, :rejection_category).to("duplicate")
      end
    end
  end

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

  describe "#rejection_description" do
    subject { cancellation.rejection_description }

    context "when there are no categories selected or reason specified" do
      let(:cancellation) { build(:cancellation, reason: nil) }

      it { is_expected.to be_nil }
    end

    context "when there is only one category selected" do
      let(:cancellation) { build(:cancellation, fully_booked: true, reason: nil) }

      it { is_expected.to eq("The date you requested is fully booked.") }
    end

    context "when there are multiple categories selected" do
      let(:cancellation) { build(:cancellation, fully_booked: true, duplicate: true, reason: nil) }

      it { is_expected.to eq("The date you requested is fully booked. This is a duplicate request.") }
    end

    context "when there is only a reason specified" do
      let(:cancellation) { build(:cancellation, reason: "Other reason.") }

      it { is_expected.to eq("Other reason.") }
    end

    context "when there are categories and a reason specified" do
      let(:cancellation) { build(:cancellation, fully_booked: true, duplicate: true, reason: "Other reason.") }

      it { is_expected.to eq("The date you requested is fully booked. This is a duplicate request. Other reason.") }
    end

    context "when there are categories including 'other' and a reason specified" do
      let(:cancellation) { build(:cancellation, other: true, duplicate: true, reason: "Other reason.") }

      it { is_expected.to eq("This is a duplicate request. Other reason.") }
    end
  end

  describe "#humanised_rejection_categories" do
    subject { cancellation.humanised_rejection_categories }

    context "when there are no categories selected or reason specified" do
      let(:cancellation) { build(:cancellation, reason: " ") }

      it { is_expected.to be_nil }
    end

    context "when multiple categories selected" do
      let(:cancellation) { build(:cancellation, fully_booked: true, duplicate: true, reason: nil) }

      it "returns the translated strings" do
        is_expected.to contain_exactly(
          "The date you requested is fully booked.",
          "This is a duplicate request."
        )
      end

      context "when 'other' is also selected'" do
        before do
          cancellation.other = true
          cancellation.reason = "Other reason."
        end

        it "returns the translated strings" do
          is_expected.to contain_exactly(
            "The date you requested is fully booked.",
            "This is a duplicate request.",
            "Other reason."
          )
        end
      end
    end

    context "when no categories have been selected but a reason is present" do
      let(:cancellation) { build(:cancellation, reason: "Other reason.") }

      it { is_expected.to contain_exactly("Other reason.") }
    end
  end
end
