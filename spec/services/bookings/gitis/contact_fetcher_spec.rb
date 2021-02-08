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
    let(:chained) do
      build :gitis_contact, :persisted, :merged, _masterid_value: merged.contactid, firstname: 'chained'
    end

    context 'for single record' do
      let(:candidate) { create :candidate, gitis_uuid: merged.contactid }
      subject { fetcher.assign_to_model candidate }

      before do
        allow(fake_gitis).to receive(:find).and_call_original
        allow(fake_gitis).to receive(:find).with(first.contactid).and_return first
        allow(fake_gitis).to receive(:find).with(second.contactid).and_return second
        allow(fake_gitis).to receive(:find).with(merged.contactid).and_return merged
        allow(fake_gitis).to receive(:find).with(chained.contactid).and_return chained
      end

      it 'should locate the master contact record' do
        is_expected.to have_attributes gitis_contact: first
      end
      it 'should not update the gitis UUID to match the master contact record' do
        is_expected.to have_attributes gitis_uuid: merged.contactid
      end
      it { is_expected.to have_attributes changes: {} }

      context 'with chained records' do
        let(:candidate) { create :candidate, gitis_uuid: chained.contactid }

        it 'should locate the master contact record' do
          is_expected.to have_attributes gitis_contact: first
        end
        it 'should not update the gitis UUID to match the master contact record' do
          is_expected.to have_attributes gitis_uuid: chained.contactid
        end
        it { is_expected.to have_attributes changes: {} }
      end

      context 'with max chained records' do
        let(:fourth) { build :gitis_contact, :persisted, :merged, _masterid_value: chained.contactid }
        let(:fifth) { build :gitis_contact, :persisted, :merged, _masterid_value: fourth.contactid }
        let(:sixth) { build :gitis_contact, :persisted, :merged, _masterid_value: fifth.contactid }

        before do
          allow(fake_gitis).to receive(:find).with(fourth.contactid).and_return fourth
          allow(fake_gitis).to receive(:find).with(fifth.contactid).and_return fifth
          allow(fake_gitis).to receive(:find).with(sixth.contactid).and_return sixth
        end

        let(:candidate) { create :candidate, gitis_uuid: sixth.contactid }

        it 'should locate the master contact record' do
          is_expected.to have_attributes gitis_contact: merged
        end
        it 'should not update the gitis UUID to match the master contact record' do
          is_expected.to have_attributes gitis_uuid: sixth.contactid
        end
        it { is_expected.to have_attributes changes: {} }
      end
    end

    context 'with multiple records' do
      let(:candidate) { create :candidate, gitis_uuid: chained.contactid }
      let(:second_candidate) { create :candidate, gitis_uuid: second.contactid }

      before do
        allow(fake_gitis).to receive(:find)
          .with([chained.contactid, second.contactid]).and_return [chained, second]

        allow(fake_gitis).to receive(:find).with([merged.contactid]).and_return [merged]
        allow(fake_gitis).to receive(:find).with([first.contactid]).and_return [first]
      end

      context 'retrieving multiple records' do
        subject { fetcher.fetch_for_models [candidate, second_candidate] }

        it { is_expected.to include chained.contactid => first }
        it { is_expected.to include second.contactid => second }
      end

      context 'assigning multiple records' do
        subject { fetcher.assign_to_models [candidate, second_candidate] }

        it "will update contact ids" do
          expect(subject.map(&:reload).map(&:gitis_uuid)).to \
            eq [chained.contactid, second.contactid]
        end

        it "will return expected contacts" do
          expect(subject.map(&:gitis_contact)).to eq [first, second]
        end
      end
    end
  end
end
