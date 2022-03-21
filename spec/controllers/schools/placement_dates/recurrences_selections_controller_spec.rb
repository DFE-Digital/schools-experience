require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementDates::RecurrencesSelectionsController, type: :request do
  include_context "logged in DfE user"

  let(:school) { Bookings::School.find_by!(urn: urn).tap { |s| create :bookings_profile, school: s } }

  let(:placement_date) { create :bookings_placement_date, bookings_school: school, supports_subjects: false, recurring: true, published_at: nil }

  context '#new' do
    before do
      get new_schools_placement_date_recurrences_selection_path(placement_date.id)
    end

    it 'assigns the correct placement_date' do
      expect(assigns(:placement_date)).to eq placement_date
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    subject(:perform_request) do
      post "/schools/placement_dates/#{placement_date.id}/recurrences_selection", params: params
      response
    end

    context 'when invalid' do
      let(:params) do
        {
          schools_placement_dates_recurrences_selection: {
            start_at: nil,
            end_at: nil,
            recurrence_period: nil
          }
        }
      end

      it { is_expected.to render_template(:new) }
    end

    context 'when valid' do
      let(:beginning_of_next_week) { Date.today.next_week.beginning_of_week }
      let(:params) do
        {
          schools_placement_dates_recurrences_selection: {
            start_at: beginning_of_next_week,
            end_at: beginning_of_next_week + 6.days,
            recurrence_period: "daily"
          }
        }
      end

      it "adds an array of weekday dates to the recurrences session" do
        perform_request
        recurrences = session["date-recurrences-#{placement_date.id}"][:recurrences]
        expect(recurrences).to eq([
          beginning_of_next_week,
          beginning_of_next_week + 1.day,
          beginning_of_next_week + 2.days,
          beginning_of_next_week + 3.days,
          beginning_of_next_week + 4.days,
        ])
      end

      it { is_expected.to redirect_to new_schools_placement_date_review_recurrences_path }
    end
  end
end
