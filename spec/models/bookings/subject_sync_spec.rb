require 'rails_helper'

RSpec.describe Bookings::SubjectSync do
  include_context 'fake gitis'

  describe '.new' do
    context 'with crm' do
      subject { described_class.new(fake_gitis) }
      it { is_expected.to be_kind_of described_class }
      it { is_expected.to respond_to :synchronise }
    end

    context 'without crm' do
      it "will raise an ArgumentError" do
        expect { described_class.new }.to raise_exception(ArgumentError)
      end
    end
  end

  describe "#synchronise" do
    let(:sync) { described_class.new(fake_gitis) }

    let(:gitis_subject_1) { build(:gitis_subject) }
    let(:gitis_subject_2) { build(:gitis_subject) }
    let(:gitis_subject_3) { build(:gitis_subject, dfe_name: 'match') }
    let(:gitis_subject_4) { build(:gitis_subject) }
    let(:gitis_subject_5) { build(:gitis_subject, dfe_name: described_class::BLACKLIST.first) }

    let!(:matched1) { create(:bookings_subject, gitis_uuid: gitis_subject_1.id) }
    let!(:matched2) { create(:bookings_subject, gitis_uuid: gitis_subject_2.id) }
    let!(:unmatched) { create(:bookings_subject, name: 'Match') }
    let!(:nomatch) { create(:bookings_subject, name: 'nomatch') }
    let(:response) do
      [
        gitis_subject_1, gitis_subject_2, gitis_subject_3,
        gitis_subject_4, gitis_subject_5
      ]
    end

    before do
      expect(fake_gitis.store).to receive(:fetch).
        with(
          Bookings::Gitis::TeachingSubject,
          limit: described_class::LIMIT
        ).and_return(response)
    end

    context 'for a successful sync' do
      before { sync.synchronise }

      context 'when matched on id' do
        it "will update name" do
          expect(matched1.reload).to have_attributes(name: gitis_subject_1.dfe_name)
          expect(matched2.reload).to have_attributes(name: gitis_subject_2.dfe_name)
        end
      end

      context 'when matched on name' do
        subject { unmatched.reload }
        it { is_expected.to have_attributes(gitis_uuid: gitis_subject_3.id) }
      end

      context "with new subjects" do
        subject { Bookings::Subject.where(gitis_uuid: gitis_subject_4.id).first }
        it { is_expected.to have_attributes(name: gitis_subject_4.dfe_name) }
        it { is_expected.to have_attributes(hidden: false) }
      end

      context "with subjects it cannot match" do
        subject { nomatch.reload }
        it { is_expected.to have_attributes(name: 'nomatch') }
        it { is_expected.to have_attributes(gitis_uuid: nil) }
      end

      context "with blacklisted new subject" do
        subject { Bookings::Subject.unscoped.where(gitis_uuid: gitis_subject_5.id).first }
        it { is_expected.to have_attributes(name: gitis_subject_5.dfe_name) }
        it { is_expected.to have_attributes(hidden: true) }
      end
    end

    context 'with more than can be handled in a single batch' do
      let(:response) do
        (1..(described_class::LIMIT + 1)).map do
          build(:gitis_subject)
        end
      end

      it "will raise an exception" do
        expect { sync.synchronise }.to \
          raise_exception(Bookings::SubjectSync::TooManySubjects)
      end
    end
  end
end
