require 'rails_helper'

RSpec.describe Candidates::SchoolsController, type: :request do
  context "GET #index" do
    before { get candidates_schools_path }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "includes the search form" do
      expect(response.body).to match(/Find.*experience/i)
    end

    it "excludes the search results" do
      expect(response.body).to_not match(/experience near/i)
    end
  end

  context "GET #index with search params" do
    let(:query_params) {
      {
        query: 'Something',
        location: 'Manchester',
        latitude: '53.481',
        longitude: '-2.241',
        distance: '10',
        phases: %w{1},
        subjects: %w{2 3},
        max_fee: '30',
        order: 'Name'
      }
    }

    before { get candidates_schools_path(query_params) }

    it "assigns params to search model" do
      expect(assigns(:search).query).to eq('Something')
      expect(assigns(:search).location).to eq('Manchester')
      expect(assigns(:search).latitude).to eq('53.481')
      expect(assigns(:search).longitude).to eq('-2.241')
      expect(assigns(:search).distance).to eq(10)
      expect(assigns(:search).phases).to eq([1])
      expect(assigns(:search).subjects).to eq([2, 3])
      expect(assigns(:search).max_fee).to eq('30')
      expect(assigns(:search).order).to eq('Name')
    end
  end

  context "GET #show" do
    before do
      @school = create(:bookings_school)
      get candidates_school_path(@school)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
      expect(response).to render_template('show')
      expect(assigns(:school)).to_not be_nil
    end
  end
end
