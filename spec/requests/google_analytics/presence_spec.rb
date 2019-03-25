require 'rails_helper'

describe "candidates/home/index.html.erb", type: :request do
  let(:tracking_id_key) { "GA_TRACKING_ID" }
  let(:tracking_id) { "AAAAABBBBBCCCCCDDDDDEEEEE" }

  let(:ga_identifiers) do
    [
      '<script async src="https://www.googletagmanager.com/gtag/js?id=AAAAABBBBBCCCCCDDDDDEEEEE"></script>',
      'gtag("config", "AAAAABBBBBCCCCCDDDDDEEEEE");'
    ]
  end

  context 'When GA_TRACKING_ID is present in the environment' do
    before do
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
