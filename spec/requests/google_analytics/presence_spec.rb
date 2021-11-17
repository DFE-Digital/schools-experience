require 'rails_helper'

describe "candidates/home/index.html.erb", type: :request do
  let(:tracking_id_key) { "GA_TRACKING_ID" }
  let(:tracking_id) { "AAAAABBBBBCCCCCDDDDDEEEEE" }

  let(:ga_identifiers) do
    [
      '<script src="https://www.google-analytics.com/analytics.js" nonce="noncevalue" async="async"></script>',
      "ga('create', '#{tracking_id}', 'none');"
    ]
  end

  context 'When GA_TRACKING_ID is present in the environment' do
    before do
      allow_any_instance_of(ActionController::Base::HelperMethods).to receive(:content_security_policy_nonce).and_return('noncevalue')
      allow_any_instance_of(CookiePreference).to receive(:allowed?).with(:analytics).and_return(true)

      @orig_tracking_id = ENV[tracking_id_key]
      ENV[tracking_id_key] = tracking_id
    end

    after { ENV[tracking_id_key] = @orig_tracking_id }

    specify "google analytics partial should be present" do
      get '/'

      expect(response.body).to include(*ga_identifiers)
    end
  end

  context "When GA_TRACKING_ID is not present in the environment" do
    before do
      @orig_tracking_id = ENV[tracking_id_key]
      ENV[tracking_id_key] = ""
    end

    after { ENV[tracking_id_key] = @orig_tracking_id }

    specify "google analytics partial should not be present" do
      get '/'

      expect(response.body).not_to include(*ga_identifiers)
    end
  end
end
