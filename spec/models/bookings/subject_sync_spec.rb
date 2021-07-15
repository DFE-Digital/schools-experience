require 'rails_helper'

RSpec.describe Bookings::SubjectSync do
  describe '.new' do
    context 'init' do
      subject { described_class.new }
      it { is_expected.to be_kind_of described_class }
      it { is_expected.to respond_to :synchronise }
    end
  end

  describe "#synchronise" do
    let(:sync) { described_class.new }

    let(:gitis_subject_1) { build(:api_teaching_subject) }
    let(:gitis_subject_2) { build(:api_teaching_subject) }
    let(:gitis_subject_3) { build(:api_teaching_subject, value: 'match') }
    let(:gitis_subject_4) { build(:api_teaching_subject) }
    let(:gitis_subject_5) { build(:api_teaching_subject, value: described_class::BLACKLIST.first) }

    let!(:matched1) { create(:bookings_subject, gitis_uuid: gitis_subject_1.id) }
    let!(:matched2) { create(:bookings_subject, gitis_uuid: gitis_subject_2.id) }
    let!(:unmatched) { create(:bookings_subject, name: 'Match') }
    let!(:nomatch) { create(:bookings_subject, name: 'nomatch') }
    let(:response) do
      [
        gitis_subject_1,
        gitis_subject_2,
        gitis_subject_3,
        gitis_subject_4,
        gitis_subject_5
      ]
    end

    before do
      expect_any_instance_of(GetIntoTeachingApiClient::LookupItemsApi).to \
        receive(:get_teaching_subjects) { response }
    end

    context 'for a successful sync' do
      context 'when matched on id' do
        before { sync.synchronise }
        it "will update name" do
          expect(matched1.reload).to have_attributes(name: gitis_subject_1.value)
          expect(matched2.reload).to have_attributes(name: gitis_subject_2.value)
        end
      end

      context 'when matched on name' do
        before { sync.synchronise }
        subject { unmatched.reload }
        it { is_expected.to have_attributes(gitis_uuid: gitis_subject_3.id) }
      end

      context "with new subjects" do
        before { sync.synchronise }
        subject { Bookings::Subject.where(gitis_uuid: gitis_subject_4.id).first }
        it { is_expected.to have_attributes(name: gitis_subject_4.value) }
        it { is_expected.to have_attributes(hidden: false) }
      end

      context "with subjects it cannot match" do
        before { sync.synchronise }
        subject { nomatch.reload }
        it { is_expected.to have_attributes(name: 'nomatch') }
        it { is_expected.to have_attributes(gitis_uuid: nil) }
      end

      context "with blacklisted new subject" do
        before { sync.synchronise }
        subject { Bookings::Subject.unscoped.where(gitis_uuid: gitis_subject_5.id).first }
        it { is_expected.to have_attributes(name: gitis_subject_5.value) }
        it { is_expected.to have_attributes(hidden: true) }
      end

      context "with blacklisted existing subject" do
        before { Bookings::Subject.create!(name: gitis_subject_5.value, hidden: true) }
        before { sync.synchronise }
        subject { Bookings::Subject.unscoped.where(gitis_uuid: gitis_subject_5.id).first }
        it { is_expected.to have_attributes(name: gitis_subject_5.value) }
        it { is_expected.to have_attributes(hidden: true) }
      end
    end

    context 'with more than can be handled in a single batch' do
      let(:response) do
        (1..(described_class::LIMIT + 1)).map do
          build(:api_lookup_item)
        end
      end

      it "will raise an exception" do
        expect { sync.synchronise }.to \
          raise_exception(Bookings::SubjectSync::TooManySubjects)
      end
    end
  end
end
