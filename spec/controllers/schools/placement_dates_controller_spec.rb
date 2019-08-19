require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementDatesController, type: :request do
  include_context "logged in DfE user"

  let! :school do
    Bookings::School.find_by!(urn: urn).tap do |s|
      create :bookings_profile, school: s
    end
  end

  context '#edit' do
    let :placement_date do
      create :bookings_placement_date, bookings_school: school
    end

    before do
      get "/schools/placement_dates/#{placement_date.id}/edit"
    end

    it 'assigns the placement date' do
      expect(assigns(:placement_date)).to eq placement_date
    end

    it 'renders the edit template' do
      expect(response).to render_template :edit
    end
  end

  context '#update' do
    let :placement_date do
      create :bookings_placement_date, bookings_school: school
    end

    let :params do
      { bookings_placement_date: placement_date.attributes }
    end

    context 'invalid' do
      before do
        placement_date.duration = nil
        patch "/schools/placement_dates/#{placement_date.id}/", params: params
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :duration do
        placement_date.duration + 1
      end

      before do
        placement_date.duration = duration
        patch "/schools/placement_dates/#{placement_date.id}/", params: params
      end

      it 'updates the placement date' do
        expect(placement_date.reload.duration).to eq duration
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          "http://www.example.com/schools/placement_dates/#{placement_date.id}/configuration/new"
      end
    end
  end
end
