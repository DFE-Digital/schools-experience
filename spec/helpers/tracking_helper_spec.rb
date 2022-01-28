require 'rails_helper'

describe TrackingHelper, type: :helper do
  let(:tracking_id) { "AAAAABBBBBCCCCCDDDDDEEEEE" }

  describe "GTM tracking helpers" do
    context "when GTM_ID is present" do
      before { allow(ENV).to receive(:[]).with("GTM_ID") { tracking_id } }

      it { expect(gtm_enabled?).to be(true) }
      it { expect(gtm_id).to eq(tracking_id) }
    end

    context "when GTM_ID is not present" do
      it { expect(gtm_enabled?).to be(false) }
      it { expect(gtm_id).to be_nil }
    end
  end

  describe "GA tracking helpers" do
    context "when GOOGLE_ANALYTICS_ID is present" do
      before { allow(ENV).to receive(:[]).with("GA_TRACKING_ID") { tracking_id } }

      it { expect(google_analytics_enabled?).to be(true) }
      it { expect(google_analytics_tracking_id).to eq(tracking_id) }
    end

    context "when GTM_ID is not present" do
      it { expect(google_analytics_enabled?).to be(false) }
      it { expect(google_analytics_tracking_id).to be_nil }
    end
  end
end
