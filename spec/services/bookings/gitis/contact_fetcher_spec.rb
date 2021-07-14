require 'rails_helper'

describe Bookings::Gitis::ContactFetcher do
  include_context "fake gitis"
  include_context "api sign ups for requests"
  include_context "api sign up for first request"

  let(:fetcher) { described_class.new fake_gitis }
  let(:school) { create :bookings_school }
  let(:requests) { create_list :bookings_placement_request, 2, school: school }
  let(:reloaded_requests) { Bookings::PlacementRequest.find requests.map(&:id) }

  context 'been_merged?' do
    subject { fetcher.been_merged?(contact) }

    context 'correct merged' do
      let(:contact) { build(:api_schools_experience_sign_up, :merged) }
      it { is_expected.to be true }
    end

    context 'correct unmerged' do
      let(:contact) { build(:api_schools_experience_sign_up) }
      it { is_expected.to be false }
    end

    context 'merged without master' do
      let(:contact) { build(:api_schools_experience_sign_up, :merged, master_id: nil) }
      it { expect { subject }.to raise_exception Bookings::Gitis::Contact::InconsistentState }
    end

    context 'master but not merged' do
      let(:contact) { build(:api_schools_experience_sign_up, :merged, merged: false) }
      it { expect { subject }.to raise_exception Bookings::Gitis::Contact::InconsistentState }
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
    let(:first) { build :api_schools_experience_sign_up }
    let(:second) { build :api_schools_experience_sign_up }
    let(:merged) do
      build :api_schools_experience_sign_up, :merged, master_id: first.candidate_id
    end
    let(:chained) do
      build :api_schools_experience_sign_up, :merged, master_id: merged.candidate_id, first_name: 'chained'
    end

    context 'for single record' do
      let(:candidate) { create :candidate, gitis_uuid: merged.candidate_id }
      subject { fetcher.assign_to_model candidate }

      before do
        allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
          receive(:get_schools_experience_sign_up).with(first.candidate_id) { first }
        allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
          receive(:get_schools_experience_sign_up).with(second.candidate_id) { second }
        allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
          receive(:get_schools_experience_sign_up).with(merged.candidate_id) { merged }
        allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
          receive(:get_schools_experience_sign_up).with(chained.candidate_id) { chained }
      end

      it 'should locate the master contact record' do
        is_expected.to have_attributes gitis_contact: first
      end
      it 'should not update the gitis UUID to match the master contact record' do
        is_expected.to have_attributes gitis_uuid: merged.candidate_id
      end
      it { is_expected.to have_attributes changes: {} }

      context 'with chained records' do
        let(:candidate) { create :candidate, gitis_uuid: chained.candidate_id }

        it 'should locate the master contact record' do
          is_expected.to have_attributes gitis_contact: first
        end
        it 'should not update the gitis UUID to match the master contact record' do
          is_expected.to have_attributes gitis_uuid: chained.candidate_id
        end
        it { is_expected.to have_attributes changes: {} }
      end

      context 'with max chained records' do
        let(:fourth) { build :api_schools_experience_sign_up, :merged, master_id: chained.candidate_id }
        let(:fifth) { build :api_schools_experience_sign_up, :merged, master_id: fourth.candidate_id }
        let(:sixth) { build :api_schools_experience_sign_up, :merged, master_id: fifth.candidate_id }

        before do
          allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
            receive(:get_schools_experience_sign_up).with(fourth.candidate_id) { fourth }
          allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
            receive(:get_schools_experience_sign_up).with(fifth.candidate_id) { fifth }
          allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
            receive(:get_schools_experience_sign_up).with(sixth.candidate_id) { sixth }
        end

        let(:candidate) { create :candidate, gitis_uuid: sixth.candidate_id }

        it 'should locate the master contact record' do
          is_expected.to have_attributes gitis_contact: merged
        end
        it 'should not update the gitis UUID to match the master contact record' do
          is_expected.to have_attributes gitis_uuid: sixth.candidate_id
        end
        it { is_expected.to have_attributes changes: {} }
      end
    end

    context 'with multiple records' do
      let(:candidate) { create :candidate, gitis_uuid: chained.candidate_id }
      let(:second_candidate) { create :candidate, gitis_uuid: second.candidate_id }

      before do
        allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
          receive(:get_schools_experience_sign_ups)
            .with([chained.candidate_id, second.candidate_id]) { [chained, second] }
        allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
          receive(:get_schools_experience_sign_ups).with([merged.candidate_id]) { [merged] }
        allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
          receive(:get_schools_experience_sign_ups).with([first.candidate_id]) { [first] }
      end

      context 'retrieving multiple records' do
        subject { fetcher.fetch_for_models [candidate, second_candidate] }

        it { is_expected.to include chained.candidate_id => first }
        it { is_expected.to include second.candidate_id => second }
      end

      context 'assigning multiple records' do
        subject { fetcher.assign_to_models [candidate, second_candidate] }

        it "will update contact ids" do
          expect(subject.map(&:reload).map(&:gitis_uuid)).to \
            eq [chained.candidate_id, second.candidate_id]
        end

        it "will return expected contacts" do
          expect(subject.map(&:gitis_contact)).to eq [first, second]
        end
      end
    end
  end
end
