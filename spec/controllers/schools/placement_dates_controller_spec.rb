require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementDatesController, type: :request do
  include_context "logged in DfE user"

  let! :school do
    Bookings::School.find_by!(urn: urn).tap do |s|
      create :bookings_profile, school: s
    end
  end

  describe '#create' do
    before { post "/schools/placement_dates", params: params }

    context "when invalid" do
      let(:params) { { bookings_placement_date: { date: nil } } }

      it "renders the new page" do
        expect(response).to render_template :new
      end
    end

    context "when valid" do
      let(:placement_date_id) { Bookings::PlacementDate.last.id }

      context "when not recurring" do
        let(:params) { { bookings_placement_date: { date: Date.today + 1.week } } }

        it "redirects to the placement details page" do
          expect(response).to redirect_to new_schools_placement_date_placement_detail_path(
            placement_date_id: placement_date_id
          )
        end
      end

      context "when recurring" do
        let(:params) { { bookings_placement_date: { date: Date.today + 1.week, recurring: true } } }

        it "redirects to the recurrences_selection page" do
          expect(response).to redirect_to new_schools_placement_date_recurrences_selection_path(
            placement_date_id: assigns(:placement_date).id
          )
        end
      end
    end
  end

  context '#edit' do
    let(:placement_date) { create :bookings_placement_date, bookings_school: school }

    before { get "/schools/placement_dates/#{placement_date.id}/edit" }

    it 'redirects to the next step' do
      expect(response).to redirect_to new_schools_placement_date_placement_detail_path(
        placement_date_id: placement_date.id
      )
    end
  end

  context '#close' do
    let(:placement_date) { create :bookings_placement_date, :active, bookings_school: school }

    context 'when confirmed' do
      let(:params) { { schools_placement_dates_close_confirmation_form: { confirmed: true } } }

      it 'closes the date and redirects to the index page' do
        post schools_placement_date_close_path(placement_date.id), params: params

        expect(placement_date.reload.active).to be false
        expect(response).to redirect_to schools_placement_dates_path
      end
    end

    context 'when not confirmed' do
      let(:params) { { schools_placement_dates_close_confirmation_form: { confirmed: false } } }

      it 'does not close the date and redirects to the index page' do
        post schools_placement_date_close_path(placement_date.id), params: params

        expect(placement_date.reload.active).to be true
        expect(response).to redirect_to schools_placement_dates_path
      end
    end
  end
end
