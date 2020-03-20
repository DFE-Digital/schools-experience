require 'rails_helper'

RSpec.describe Candidates::SchoolSearchesController, type: :request do
  describe "GET #index" do
    before { get new_candidates_school_search_path }

    it "includes the search form" do
      expect(response.body).to match(/Search for school experience/i)
    end
  end

  context 'when candidate applications are disabled' do
    before do
      allow(Rails.application.config.x.candidates).to \
        receive(:deactivate_applications).and_return \
          "This service is not available"
    end

    describe '#index' do
      subject { get new_candidates_school_search_path; response }
      it { is_expected.to redirect_to candidates_root_path }
    end
  end
end
