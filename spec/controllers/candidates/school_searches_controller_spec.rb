require 'rails_helper'

RSpec.describe Candidates::SchoolSearchesController, type: :request do
  describe "GET #index" do
    before { get new_candidates_school_search_path }

    it "includes the search form" do
      expect(response.body).to match(/Search for school experience/i)
    end
  end

  describe "GET #new with an unreadable location" do
    %w[bad!token Rochdale].each do |token|
      it "shows the location error for #{token}" do
        get new_candidates_school_search_path(location: token, latitude: '53.4', longitude: '-2.2')

        expect(response).to have_http_status(:success)
        expect(response.body).to include(I18n.t('candidates.school_searches.unreadable_location'))
        expect(assigns(:search).latitude).to be_nil
      end
    end
  end

  context 'when candidate applications are disabled' do
    before do
      allow(Rails.application.config.x.candidates).to \
        receive(:deactivate_applications).and_return \
          "This service is not available"
    end

    describe '#index' do
      subject do
        get new_candidates_school_search_path
        response
      end
      it { is_expected.to redirect_to candidates_root_path }
    end
  end
end
