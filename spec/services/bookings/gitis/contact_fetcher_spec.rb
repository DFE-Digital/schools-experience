require 'rails_helper'

describe Bookings::Gitis::ContactFetcher do
  include_context "when the API signs up for requests"
  include_context "when the API signs up for the first request"

  let(:fetcher) { described_class.new }
  let(:school) { create :bookings_school }
  let(:requests) { create_list :bookings_placement_request, 2, school: school }
  let(:reloaded_requests) { Bookings::PlacementRequest.find requests.map(&:id) }

  context 'when been_merged?' do
    subject { fetcher.been_merged?(contact) }

    context 'when correct merged' do
      let(:contact) { build(:api_schools_experience_sign_up_with_name, :merged) }

      it { is_expected.to be true }
    end

    context 'when correct unmerged' do
      let(:contact) { build(:api_schools_experience_sign_up_with_name) }

      it { is_expected.to be false }
    end

    context 'when merged without master' do
      let(:contact) { build(:api_schools_experience_sign_up_with_name, :merged, master_id: nil) }

      it { expect { subject }.to raise_exception described_class::InconsistentContactState }
    end

    context 'when master but not merged' do
      let(:contact) { build(:api_schools_experience_sign_up_with_name, :merged, merged: false) }

      it { expect { subject }.to raise_exception described_class::InconsistentContactState }
    end
  end

  describe 'fetching contacts' do
    subject { fetcher.fetch_for_models reloaded_requests }

    it "returns a hash with contactids as keys" do
      expect(subject.keys).to eql \
        requests.map(&:candidate).map(&:gitis_uuid)
    end

    it "returns contacts as hash values" do
      expect(subject.values.map(&:candidate_id)).to eql \
        requests.map(&:candidate).map(&:gitis_uuid)
    end
  end

  describe 'assigning contacts' do
    subject { fetcher.assign_to_models reloaded_requests }

    it "assigns expected models" do
      expect(subject.map(&:gitis_contact).map(&:candidate_id)).to eql \
        requests.map(&:candidate).map(&:gitis_uuid)
    end
  end

  describe 'assign_to_model' do
    subject { fetcher.assign_to_model reloaded_requests[0] }

    it "assigns expected models" do
      expect(subject.gitis_contact.candidate_id).to eql \
        requests[0].candidate.gitis_uuid
    end
  end

  describe 'merged records' do
    let(:first) { build :api_schools_experience_sign_up_with_name }
    let(:second) { build :api_schools_experience_sign_up_with_name }
    let(:merged) do
      build :api_schools_experience_sign_up_with_name, :merged, master_id: first.candidate_id
    end
    let(:chained) do
      build :api_schools_experience_sign_up_with_name, :merged, master_id: merged.candidate_id, first_name: 'chained'
    end

    context 'with single record' do
      subject { fetcher.assign_to_model candidate }

      let(:candidate) { create :candidate, gitis_uuid: merged.candidate_id }


      before do
        api_client = stubbed_api_client(GetIntoTeachingApiClient::SchoolsExperienceApi)
        allow(api_client).to \
          receive(:get_schools_experience_sign_up).with(first.candidate_id) { first }
        allow(api_client).to \
          receive(:get_schools_experience_sign_up).with(second.candidate_id) { second }
        allow(api_client).to \
          receive(:get_schools_experience_sign_up).with(merged.candidate_id) { merged }
        allow(api_client).to \
          receive(:get_schools_experience_sign_up).with(chained.candidate_id) { chained }
      end

      it 'locates the master contact record' do
        expect(subject).to have_attributes gitis_contact: first
      end

      it 'does not update the gitis UUID to match the master contact record' do
        expect(subject).to have_attributes gitis_uuid: merged.candidate_id
      end

      it { is_expected.to have_attributes changes: {} }

      context 'with chained records' do
        let(:candidate) { create :candidate, gitis_uuid: chained.candidate_id }

        it 'locates the master contact record' do
          expect(subject).to have_attributes gitis_contact: first
        end

        it 'does not update the gitis UUID to match the master contact record' do
          expect(subject).to have_attributes gitis_uuid: chained.candidate_id
        end

        it { is_expected.to have_attributes changes: {} }
      end

      context 'with max chained records' do
        let(:fourth) { build :api_schools_experience_sign_up_with_name, :merged, master_id: chained.candidate_id }
        let(:candidate) { create :candidate, gitis_uuid: sixth.candidate_id }
        let(:fifth) { build :api_schools_experience_sign_up_with_name, :merged, master_id: fourth.candidate_id }
        let(:sixth) { build :api_schools_experience_sign_up_with_name, :merged, master_id: fifth.candidate_id }

        before do
          api_client = stubbed_api_client(GetIntoTeachingApiClient::SchoolsExperienceApi)
          allow(api_client).to \
            receive(:get_schools_experience_sign_up).with(fourth.candidate_id) { fourth }
          allow(api_client).to \
            receive(:get_schools_experience_sign_up).with(fifth.candidate_id) { fifth }
          allow(api_client).to \
            receive(:get_schools_experience_sign_up).with(sixth.candidate_id) { sixth }
        end


        it 'locates the master contact record' do
          expect(subject).to have_attributes gitis_contact: merged
        end

        it 'does not update the gitis UUID to match the master contact record' do
          expect(subject).to have_attributes gitis_uuid: sixth.candidate_id
        end

        it { is_expected.to have_attributes changes: {} }
      end
    end

    context 'with multiple records' do
      let(:candidate) { create :candidate, gitis_uuid: chained.candidate_id }
      let(:second_candidate) { create :candidate, gitis_uuid: second.candidate_id }

      before do
        api_client = stubbed_api_client(GetIntoTeachingApiClient::SchoolsExperienceApi)
        allow(api_client).to \
          receive(:get_schools_experience_sign_ups)
            .with([chained.candidate_id, second.candidate_id]) { [chained, second] }
        allow(api_client).to \
          receive(:get_schools_experience_sign_ups).with([merged.candidate_id]) { [merged] }
        allow(api_client).to \
          receive(:get_schools_experience_sign_ups).with([first.candidate_id]) { [first] }
      end

      context 'when retrieving multiple records' do
        subject { fetcher.fetch_for_models [candidate, second_candidate] }

        it { is_expected.to include chained.candidate_id => first }
        it { is_expected.to include second.candidate_id => second }
      end

      context 'when assigning multiple records' do
        subject { fetcher.assign_to_models [candidate, second_candidate] }

        it "updates contact ids" do
          expect(subject.map(&:reload).map(&:gitis_uuid)).to \
            eq [chained.candidate_id, second.candidate_id]
        end

        it "returns expected contacts" do
          expect(subject.map(&:gitis_contact)).to eq [first, second]
        end
      end
    end
  end
end
