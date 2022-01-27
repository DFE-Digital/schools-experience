require 'rails_helper'

RSpec.describe Candidates::SchoolsController, type: :request do
  context "GET #index with search params" do
    let(:query_params) do
      {
        query: 'Something',
        location: 'Manchester',
        latitude: '53.481',
        longitude: '-2.241',
        distance: '10',
        phases: %w[1],
        subjects: %w[2 3],
        max_fee: '30',
        order: 'Name',
        dbs_policies: %w[1],
        disability_confident: '1',
        parking: '1'
      }
    end

    before { get candidates_schools_path(query_params) }

    it "assigns params to search model" do
      expect(assigns(:search).query).to eq('Something')
      expect(assigns(:search).location).to eq('Manchester')
      expect(assigns(:search).latitude).to eq('53.481')
      expect(assigns(:search).longitude).to eq('-2.241')
      expect(assigns(:search).phases).to eq([1])
      expect(assigns(:search).subjects).to eq([2, 3])
      expect(assigns(:search).max_fee).to eq('30')
      expect(assigns(:search).dbs_policies).to eq([1])
      expect(assigns(:search).disability_confident).to eq('1')
      expect(assigns(:search).parking).to eq('1')

      # note, this search will yield no results so the search radius will
      # automatically be expanded from 10 to the value at EXPANDED_SEARCH_RADIUS
      expect(assigns(:search).distance).to eq(Candidates::SchoolsController::EXPANDED_SEARCH_RADIUS)
    end

    context 'when location and coordinates are blank' do
      let(:query_params) do
        {
          query: 'Something',
          location: '',
          latitude: '',
          longitude: '',
          distance: '10',
          phases: %w[1],
          subjects: %w[2 3],
          max_fee: '30',
          order: 'Name',
          dbs_policies: %w[1]
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

    it "renders a meta description tag" do
      expect(response.body).to include("<meta name=\"description\" content=\"#{school.name} is offering")
    end
  end

  context 'when candidate applications are deactivated' do
    before do
      allow(Rails.application.config.x.candidates).to \
        receive(:deactivate_applications).and_return \
          "This service is not available"
    end

    let(:school) { create :bookings_school }

    describe '#index' do
      subject do
        get candidates_schools_path
        response
      end
      it { is_expected.to redirect_to candidates_root_path }
    end

    describe '#show' do
      subject do
        get candidates_school_path(school)
        response
      end
      it { is_expected.to redirect_to candidates_root_path }
    end
  end

  context 'when urns whitelisted' do
    let(:school) { create :bookings_school }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('CANDIDATE_URN_WHITELIST') { whitelist }
    end

    describe '#show' do
      context 'when in whitelist' do
        let(:whitelist) { school.urn.to_s }
        subject do
          get candidates_school_path(school)
          response
        end
        it { is_expected.to have_rendered 'show' }
      end

      context 'when not in whitelist' do
        let(:whitelist) { '-1' }
        subject do
          get candidates_school_path(school)
          response
        end
        it { is_expected.to redirect_to candidates_root_path }
      end
    end
  end
end
