require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementDates::ReviewRecurrencesController, type: :request do
  include_context "logged in DfE user"

  let(:school) { Bookings::School.find_by!(urn: urn).tap { |s| create :bookings_profile, school: s } }
  let(:placement_date) { create(:bookings_placement_date, bookings_school: school, supports_subjects: false, recurring: true) }
  let(:beginning_of_next_week) { placement_date.date.next_week.beginning_of_week }
  let(:recurring_dates) { [beginning_of_next_week + 1.day, beginning_of_next_week + 2.days] }

  before do
    params = {
      schools_placement_dates_recurrences_selection: {
        start_at: recurring_dates.first,
        end_at: recurring_dates.last,
        recurrence_period: "daily"
      }
    }

    post schools_placement_date_recurrences_selection_path(placement_date.id), params: params
  end

  context "#new" do
    before do
      get new_schools_placement_date_review_recurrences_path(placement_date.id)
    end

    it { expect(assigns(:selected_dates)).to eq(recurring_dates) }
    it { is_expected.to render_template(:new) }

    it "renders dates for the next 6 months, excluding weekdays" do
      dates_by_month = assigns(:dates_by_month)

      expect(dates_by_month.count).to eq(6)

      first_month = dates_by_month[0][0]
      first_month_dates = dates_by_month[0][1]
      expected_date = placement_date.date + 1.day

      expect(first_month).to eq(expected_date.to_formatted_s(:govuk_month_only))
      expect(first_month_dates).to all(be_on_weekday)
      expect(first_month_dates.map(&:month)).to all(eq(expected_date.month))
      expect(first_month_dates.uniq.count).to eq(first_month_dates.count)
    end
  end

  context "#create" do
    let(:submitted_dates) { recurring_dates + [beginning_of_next_week + 3.days] }

    before do
      post schools_placement_date_review_recurrences_path(placement_date.id), params: { dates: submitted_dates }
    end

    it { is_expected.to redirect_to new_schools_placement_date_placement_detail_path }
    it { expect(request.session["date-recurrences-#{placement_date.id}"][:recurrences]).to eq(submitted_dates) }
  end
end
