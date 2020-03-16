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
end
