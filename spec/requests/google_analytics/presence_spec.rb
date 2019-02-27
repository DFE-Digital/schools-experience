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
      allow(ENV).to(
        receive(:has_key?)
          .with(tracking_id_key)
          .and_return(true)
      )
      allow(ENV).to(
        receive(:fetch)
          .with(tracking_id_key)
          .and_return(tracking_id)
      )
    end

    specify "google analytics partial should be present" do
      get '/'

      expect(response.body).to include(*ga_identifiers)
    end
  end

  context "When GA_TRACKING_ID is not present in the environment" do
    before do
      allow(ENV).to(
        receive(:has_key?)
          .with(tracking_id_key)
          .and_return(false)
      )
    end

    specify "google analytics partial should not be present" do
      get '/'

      expect(response.body).not_to include(*ga_identifiers)
    end
  end
end
