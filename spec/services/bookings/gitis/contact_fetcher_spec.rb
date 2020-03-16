require 'rails_helper'

describe Bookings::Gitis::ContactFetcher do
  include_context "fake gitis"

  let(:fetcher) { described_class.new fake_gitis }
  let(:school) { create :bookings_school }
  let(:requests) { create_list :bookings_placement_request, 2, school: school }
  let(:reloaded_requests) { Bookings::PlacementRequest.find requests.map(&:id) }

  describe 'fetching contacts' do
    subject { fetcher.fetch_for_models reloaded_requests }

    it "should return hash with contactids as keys" do
      expect(subject.keys).to eql \
        requests.map(&:candidate).map(&:gitis_uuid)
    end

    it "should return contacts as hash values" do
      expect(subject.values.map(&:contactid)).to eql \
        requests.map(&:candidate).map(&:gitis_uuid)
    end
  end

  describe 'assigning contacts' do
    subject { fetcher.assign_to_models reloaded_requests }

    it "should assign expected models" do
      expect(subject.map(&:gitis_contact).map(&:contactid)).to eql \
        requests.map(&:candidate).map(&:gitis_uuid)
    end
  end

  describe 'assign_to_model' do
    subject { fetcher.assign_to_model reloaded_requests[0] }

    it "should assign expected models" do
      expect(subject.gitis_contact.contactid).to eql \
        requests[0].candidate.gitis_uuid
    end
  end

  describe 'merged records' do
    let(:first) { build :gitis_contact, :persisted }
    let(:second) { build :gitis_contact, :persisted }
    let(:merged) do
      build :gitis_contact, :persisted, :merged, _masterid_value: first.contactid
    end
    let(:third) do
      build :gitis_contact, :persisted, :merged, _masterid_value: merged.contactid
    end

    context 'for single record' do
      before do
        allow(fake_gitis).to receive(:find).and_call_original
        allow(fake_gitis).to receive(:find).with(first.contactid).and_return first
        allow(fake_gitis).to receive(:find).with(merged.contactid).and_return merged
        allow(fake_gitis).to receive(:find).with(third.contactid).and_return third
      end

      let(:candidate) { create :candidate, gitis_uuid: merged.contactid }
      subject { fetcher.assign_to_model candidate }

      it { is_expected.to have_attributes gitis_contact: first }
      it { is_expected.to have_attributes gitis_uuid: first.contactid }
      it { is_expected.to have_attributes changes: {} }

      context 'with chained records' do
        let(:candidate) { create :candidate, gitis_uuid: third.contactid }
        it { is_expected.to have_attributes gitis_contact: first }
        it { is_expected.to have_attributes gitis_uuid: first.contactid }
        it { is_expected.to have_attributes changes: {} }
      end

      context 'with max chained records' do
        let(:fourth) { build :gitis_contact, :persisted, :merged, _masterid_value: third.contactid }
        let(:fifth) { build :gitis_contact, :persisted, :merged, _masterid_value: fourth.contactid }
        let(:sixth) { build :gitis_contact, :persisted, :merged, _masterid_value: fifth.contactid }

        before do
          allow(fake_gitis).to receive(:find).with(fourth.contactid).and_return fourth
          allow(fake_gitis).to receive(:find).with(fifth.contactid).and_return fifth
          allow(fake_gitis).to receive(:find).with(sixth.contactid).and_return sixth
        end

        let(:candidate) { create :candidate, gitis_uuid: sixth.contactid }

        it { is_expected.to have_attributes gitis_contact: merged }
        it { is_expected.to have_attributes gitis_uuid: merged.contactid }
        it { is_expected.to have_attributes changes: {} }
      end
    end
  end
end
