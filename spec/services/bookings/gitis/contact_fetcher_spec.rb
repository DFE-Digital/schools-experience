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
      let(:contact) { build(:gitis_contact, :merged) }
      it { is_expected.to be true }
    end

    context 'correct unmerged' do
      let(:contact) { build(:gitis_contact, :persisted) }
      it { is_expected.to be false }
    end

    context 'merged without master' do
      let(:contact) { build(:gitis_contact, :merged, _masterid_value: nil) }
      it { expect { subject }.to raise_exception Bookings::Gitis::Contact::InconsistentState }
    end

    context 'master but not merged' do
      let(:contact) { build(:gitis_contact, :merged, merged: false) }
      it { expect { subject }.to raise_exception Bookings::Gitis::Contact::InconsistentState }
    end
  end

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

    context "when the git_api feature is enabled" do
      around do |example|
        Flipper.enable(:git_api)
        example.run
        Flipper.disable(:git_api)
      end

      it "returns a hash with contactids as keys" do
        expect(subject.keys).to eql \
          requests.map(&:candidate).map(&:gitis_uuid)
      end

      it "returns contacts as hash values" do
        expect(subject.values.map(&:candidate_id)).to eql \
          requests.map(&:candidate).map(&:gitis_uuid)
      end
    end
  end

  describe 'assigning contacts' do
    subject { fetcher.assign_to_models reloaded_requests }

    it "should assign expected models" do
      expect(subject.map(&:gitis_contact).map(&:contactid)).to eql \
        requests.map(&:candidate).map(&:gitis_uuid)
    end

    context "when the git_api feature is enabled" do
      around do |example|
        Flipper.enable(:git_api)
        example.run
        Flipper.disable(:git_api)
      end

      it "assigns expected models" do
        expect(subject.map(&:gitis_contact).map(&:candidate_id)).to eql \
          requests.map(&:candidate).map(&:gitis_uuid)
      end
    end
  end

  describe 'assign_to_model' do
    subject { fetcher.assign_to_model reloaded_requests[0] }

    it "should assign expected models" do
      expect(subject.gitis_contact.contactid).to eql \
        requests[0].candidate.gitis_uuid
    end

    context "when the git_api feature is enabled" do
      around do |example|
        Flipper.enable(:git_api)
        example.run
        Flipper.disable(:git_api)
      end

      it "assigns expected models" do
        expect(subject.gitis_contact.candidate_id).to eql \
          requests[0].candidate.gitis_uuid
      end
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

  context "when the git_api feature is enabled" do
    around do |example|
      Flipper.enable(:git_api)
      example.run
      Flipper.disable(:git_api)
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
end
