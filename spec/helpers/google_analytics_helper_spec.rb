require 'rails_helper'

describe GoogleAnalyticsHelper, type: :helper do
  let(:tracking_id_key) { "GA_TRACKING_ID" }
  let(:tracking_id) { "AAAAABBBBBCCCCCDDDDDEEEEE" }

  describe '#google_analytics_enabled?' do
    context 'when GA_TRACKING_ID is present' do
      before do
        allow(ENV).to(receive(:[]).and_return(tracking_id_key))
      end

      specify { expect(google_analytics_enabled?).to be true }
    end

    context 'when GA_TRACKING_ID is not present' do
      specify { expect(google_analytics_enabled?).to be false }
    end
  end

  describe '#google_analytics_tracking_id' do
    context 'when GA_TRACKING_ID is present' do
      before do
        allow(ENV).to(
          receive(:fetch)
            .with(tracking_id_key)
            .and_return(tracking_id)
        )
      end

      specify { expect(google_analytics_tracking_id).to eql(tracking_id) }
    end

    context 'when GA_TRACKING_ID is not present' do
      specify do
        expect { google_analytics_tracking_id }.to raise_error(KeyError)
      end
    end
  end
end
