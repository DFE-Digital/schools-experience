require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementDates::ReviewRecurrencesController, type: :request do
  include_context "logged in DfE user"

  let(:school) { Bookings::School.find_by!(urn: urn).tap { |s| create :bookings_profile, school: s } }
  let(:first_weekday_next_month) { (Date.today + 1.month).beginning_of_month.next_occurring(:monday) }
  let(:placement_date) { create(:bookings_placement_date, date: first_weekday_next_month, bookings_school: school, supports_subjects: false, recurring: true) }
  let(:date_range) { [placement_date.date, placement_date.date + 1.month] }

  before do
    params = {
      schools_placement_dates_recurrences_selection: {
        start_at: date_range.first,
        end_at: date_range.last,
        recurrence_period: "daily"
      }
    }

    post schools_placement_date_recurrences_selection_path(placement_date.id), params: params
  end

  context "#new" do
    before do
      get new_schools_placement_date_review_recurrences_path(placement_date.id)
    end

    it { is_expected.to render_template(:new) }

    it "renders recurring dates" do
      dates_by_month = assigns(:dates_by_month)

      expect(dates_by_month.count).to eq(2)

      month_names = dates_by_month.map(&:first)
      expect(month_names).to eq([
        date_range.first.to_formatted_s(:govuk_month_only),
        date_range.last.to_formatted_s(:govuk_month_only),
      ])

      dates = dates_by_month.map(&:last).flatten
      expect(dates).to eq(((date_range.first + 1.day)..date_range.last).reject(&:on_weekend?).to_a)
    end
  end

  context "#create" do
    let(:submitted_dates) { date_range }

    before do
      post schools_placement_date_review_recurrences_path(placement_date.id), params: { dates: submitted_dates }
    end

    it { is_expected.to redirect_to new_schools_placement_date_placement_detail_path }
    it { expect(request.session["date-recurrences-#{placement_date.id}"][:recurrences]).to eq(submitted_dates) }
  end
end
