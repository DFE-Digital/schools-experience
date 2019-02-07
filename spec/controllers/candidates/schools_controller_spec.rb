require 'rails_helper'

RSpec.describe Candidates::SchoolsController, type: :request do
  context "GET #index" do
    before { get candidates_schools_path }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "includes the search form" do
      expect(response.body).to match(/Find.*placement/i)
    end

    it "excludes the search results" do
      expect(response.body).to_not match(/School experience placements near/i)
    end
  end

  context "GET #show" do
    before do
      @school = create(:bookings_school)
      get candidates_school_path(@school.urn)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
      expect(response).to render_template('show')
      expect(assigns(:school)).to_not be_nil
    end
  end
end
