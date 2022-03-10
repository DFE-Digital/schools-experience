require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementDates::PublishDatesController, type: :request do
  include_context "logged in DfE user"

  let(:school) { Bookings::School.find_by!(urn: urn).tap { |s| create :bookings_profile, school: s } }
  let(:placement_date) { create(:bookings_placement_date, bookings_school: school, supports_subjects: false, recurring: true) }
  let(:beginning_of_next_week) { placement_date.date.next_week.beginning_of_week }
  let(:date_range) { [beginning_of_next_week + 1.day, beginning_of_next_week + 1.month] }

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
      get new_schools_placement_date_publish_dates_path(placement_date.id)
    end

    it { is_expected.to render_template(:new) }
  end

  context "#create" do
    let(:submitted_dates) { date_range }

    before do
      post schools_placement_date_publish_dates_path(placement_date.id)
    end

    it { is_expected.to redirect_to schools_placement_dates_path }

    it "publishes the date and any recurrences" do
      placement_date.reload

      expect(placement_date).to be_active
      expect(placement_date.published_at.to_date).to eq(Date.today)
    end
  end
end
