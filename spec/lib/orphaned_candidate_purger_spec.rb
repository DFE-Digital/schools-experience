require "rails_helper"
require "orphaned_candidate_purger"

RSpec.describe OrphanedCandidatePurger do
  include ActiveSupport::Testing::TimeHelpers

  let(:dry_run) { false }
  let(:instance) { described_class.new(dry_run: dry_run) }

  describe "#purge!" do
    let!(:candidates) do
      travel_to 2.days.ago do
        2.times.collect { create(:candidate) }
      end
    end
    let!(:orphans) do
      travel_to 2.days.ago do
        3.times.collect { create(:candidate) }
      end
    end
    let!(:recent_orphans) { 2.times.collect { create(:candidate) } }

    before do
      candidate_uuids = candidates.map(&:gitis_uuid)
      orphan_uuids = orphans.map(&:gitis_uuid)
      requested_uuids = candidate_uuids + orphan_uuids

      allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
        receive(:get_schools_experience_sign_ups).with(requested_uuids) do
          candidate_uuids.map do |id|
            GetIntoTeachingApiClient::SchoolsExperienceSignUp.new(
              candidate_id: id,
              merged: false
            )
          end
        end
    end

    subject(:purge) { instance.purge! }

    it "deletes orphaned candidates created more than a day ago" do
      expect { purge }.to change(Bookings::Candidate, :count).by(-orphans.count)

      orphans.each do |orphan|
        expect { orphan.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when dry_run is true" do
      let(:dry_run) { true }

      it "does not delete candidates" do
        expect(Rails.logger).to receive(:info).with("Orphaned candidates", orphans)

        expect { purge }.not_to change(Bookings::Candidate, :count)
      end
    end
  end
end
