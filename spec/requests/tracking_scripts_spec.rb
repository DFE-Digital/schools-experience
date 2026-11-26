require "rails_helper"

describe "Tracking Scripts", type: :request do
  subject do
    get root_path
    response.body
  end

  let(:tracking_id) { "AAAAABBBBBCCCCCDDDDDEEEEE" }

  before { allow(ENV).to receive(:[]).and_call_original }


  describe "Google Tag Manager" do
    let(:tracking_id_key) { "GTM_ID" }
    let(:gtm_script) { %r{<script src="/assets/gtm-.*\.js" defer="defer" data-gtm-id="#{tracking_id}" data-gtm-nonce=".*"></script>} }
    let(:gtm_noscript) { %(https://www\.googletagmanager\.com/ns\.html\?id=#{tracking_id}") }

    context "when the user has accepted analytics cookies and GTM_ID is present in the environment" do
      before do
        cookie_preference = instance_double(CookiePreference, allowed?: true)
        allow(CookiePreference).to receive(:new).and_return(cookie_preference)
        allow(ENV).to receive(:[]).with("GTM_ID") { tracking_id }
      end

      it { is_expected.to match(gtm_script) }
      it { is_expected.to include(gtm_noscript) }
      it { is_expected.to include(%(class="gtm-noscript-hidden")) }
      it { is_expected.not_to match(/<iframe[^>]*style=/) }
    end

    context "when GTM_ID is not present in the environment" do
      before do
        allow(ENV).to receive(:[]).with("GTM_ID").and_return("")
      end

      it { is_expected.not_to match(gtm_script) }
      it { is_expected.not_to include(gtm_noscript) }
    end
  end
end
