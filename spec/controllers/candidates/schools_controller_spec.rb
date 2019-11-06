require 'rails_helper'

RSpec.describe Candidates::SchoolsController, type: :request do
  let!(:primary_phase) { create :bookings_phase, :primary }
  let!(:secondary_phase) { create :bookings_phase, :secondary }
  let!(:college_phase) { create :bookings_phase, :college }

  context "GET #index with search params" do
    let(:query_params) {
      {
        query: 'Something',
        location: 'Manchester',
        distance: '10',
        age_group: 'primary',
        subjects: %w{2 3},
        max_fee: '30',
        order: 'Name'
      }
    }

    before { get candidates_schools_path(query_params) }

    it "assigns params to search model" do
      expect(assigns(:search).query).to eq('Something')
      expect(assigns(:search).location).to eq('Manchester')
      expect(assigns(:search).phases).to eq([primary_phase.id])
      expect(assigns(:search).subjects).to eq([2, 3])
      expect(assigns(:search).max_fee).to eq('30')
      expect(assigns(:search).order).to eq('Name')

      # note, this search will yield no results so the search radius will
      # automatically be expanded from 10 to the value at EXPANDED_SEARCH_RADIUS
      expect(assigns(:search).distance).to eq(Candidates::SchoolsController::EXPANDED_SEARCH_RADIUS)
    end

    context 'when location and coordinates are blank' do
      let(:query_params) do
        {
          query: 'Something',
          location: '',
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

      context 'when location is present' do
        let(:query_params_with_location) do
          query_params.merge(location: 'Rochdale')
        end

        before { get candidates_schools_path(query_params_with_location) }

        specify { expect(response).to have_http_status(:success) }
      end

      context 'when location is absent' do
        let(:query_params_with_location) do
          query_params.merge(location: nil)
        end

        before { get candidates_schools_path(query_params_with_location) }

        specify { expect(response).to redirect_to new_candidates_school_search_path }
      end
    end

    context 'analytics tracking' do
      # set the uuid cookie, grab it then do a search
      before { get new_candidates_school_search_path }
      before { @uuid = cookies[:analytics_tracking_uuid] }
      before { get candidates_schools_path(query_params) }

      specify 'should persist the analytics_tracking_uuid if present' do
        expect(Bookings::SchoolSearch.last.analytics_tracking_uuid).to eql(@uuid)
      end

      specify 'make sure it looks like a UUID' do
        @uuid.split('-').tap do |parts|
          expect(parts.map(&:length)).to eql([8, 4, 4, 4, 12])
          expect(parts).to all(match(/[0-9a-f]/))
        end
      end

      specify 'should be HTTP-only' do
        expect(cookies.get_cookie("analytics_tracking_uuid")).to be_http_only
      end
    end
  end

  context "GET #show" do
    let(:school) { create(:bookings_school) }
    let(:req) { get candidates_school_path(school) }
    subject! { req }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "renders the correct template" do
      expect(subject).to render_template('show')
    end

    it "assigns the the school" do
      expect(assigns(:school)).to_not be_nil
    end

    context 'counting' do
      let!(:count) { school.views }
      before { req }

      specify 'count should have increased when viewed' do
        expect(school.reload.views).to eql(count + 1)
      end
    end
  end
end
