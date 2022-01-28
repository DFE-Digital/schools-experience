require "rails_helper"

describe "Tracking Scripts", type: :request do
  let(:tracking_id) { "AAAAABBBBBCCCCCDDDDDEEEEE" }

  before { allow(ENV).to receive(:[]).and_call_original }

  subject do
    get root_path
    response.body
  end

  describe "Google Analytics" do
    let(:tracking_id_key) { "GA_TRACKING_ID" }
    let(:ga_identifiers) do
      [
        '<script src="https://www.google-analytics.com/analytics.js" nonce="noncevalue" async="async"></script>',
        "ga('create', '#{tracking_id}', 'none');"
      ]
    end

    context "when the user has accepted analytics cookies and GA_TRACKING_ID is present in the environment" do
      before do
        allow_any_instance_of(ActionController::Base::HelperMethods).to receive(:content_security_policy_nonce).and_return('noncevalue')
        allow_any_instance_of(CookiePreference).to receive(:allowed?).with(:analytics).and_return(true)
        allow(ENV).to receive(:[]).with("GA_TRACKING_ID") { tracking_id }
      end

      it { is_expected.to include(*ga_identifiers) }
    end

    context "When GA_TRACKING_ID is not present in the environment" do
      before do
        allow(ENV).to receive(:[]).with("GA_TRACKING_ID") { "" }
      end

      it { is_expected.not_to include(*ga_identifiers) }
    end
  end

  describe "Google Tag Manager" do
    let(:tracking_id_key) { "GTM_ID" }
    let(:gtm_script) { %r{<script src="/packs-test/js/gtm-.*\.js" data-gtm-id="#{tracking_id}" data-gtm-nonce=".*"></script>} }
    let(:gtm_noscript) { %(https://www\.googletagmanager\.com/ns\.html\?id=#{tracking_id}") }

    context "when the user has accepted analytics cookies and GTM_ID is present in the environment" do
      before do
        allow_any_instance_of(CookiePreference).to receive(:allowed?).with(:analytics).and_return(true)
        allow(ENV).to receive(:[]).with("GTM_ID") { tracking_id }
      end

      it { is_expected.to match(gtm_script) }
      it { is_expected.to include(gtm_noscript) }
    end

    context "When GTM_ID is not present in the environment" do
      before do
        allow(ENV).to receive(:[]).with("GTM_ID") { "" }
      end

      it { is_expected.not_to match(gtm_script) }
      it { is_expected.not_to include(gtm_noscript) }
    end
  end
end
