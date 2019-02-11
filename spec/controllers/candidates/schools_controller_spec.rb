require 'rails_helper'

RSpec.describe Candidates::SchoolsController, type: :request do
  before do
    allow(Geocoder).to receive(:search).and_return([
      OpenStruct.new(data: {'lat' => "53.4794892", 'lon' => "-2.2451148"})
    ])
  end

  context "GET #index" do
    before { get candidates_schools_path }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "includes the search form" do
      expect(response.body).to match(/Find.*placement/i)
    end

    it "excludes the search results" do
      expect(response.body).to_not match(/placements near/i)
    end
  end

  context "GET #index with search params" do
    let(:query_params) {
      {
        query: 'Something',
        location: 'Manchester',
        distance: '10',
        phases: ['1'],
        subjects: ['2','3'],
        max_fee: '30',
        order: 'Name'
      }
    }

    before { get candidates_schools_path(query_params) }

    it "assigns params to search model" do
      expect(assigns(:search).query).to eq('Something')
      expect(assigns(:search).location).to eq('Manchester')
      expect(assigns(:search).distance).to eq(10)
      expect(assigns(:search).phases).to eq([1])
      expect(assigns(:search).subjects).to eq([2,3])
      expect(assigns(:search).max_fee).to eq('30')
      expect(assigns(:search).order).to eq('Name')
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
