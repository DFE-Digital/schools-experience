require 'rails_helper'

RSpec.describe Candidates::SchoolsController, type: :request do
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

    context 'when location and coordinates are blank' do
      let(:query_params) do
        {
          query: 'Something',
          location: '',
          latitude: '',
          longitude: '',
          distance: '10',
          phases: %w{1},
          subjects: %w{2 3},
          max_fee: '30',
          order: 'Name'
        }
      end

      it 'redirects to the search page' do
        expect(subject).to redirect_to(new_candidates_school_search_path)
      end

      context 'when coordinates are blank and location is present' do
        let(:query_params_with_location) do
          query_params.merge(location: 'Rochdale')
        end

        before { get candidates_schools_path(query_params_with_location) }

        specify { expect(response).to have_http_status(:success) }
      end

      context 'when coordinates are present and location is blank' do
        let(:query_params_with_coordinates) do
          query_params.merge(latitude: 53.479, longitude: -245)
        end

        before { get candidates_schools_path(query_params_with_coordinates) }

        specify { expect(response).to have_http_status(:success) }
      end
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
