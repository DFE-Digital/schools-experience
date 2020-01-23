require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementDates::DateLimitsController, type: :request do
  include_context "logged in DfE user"

  let :school do
    Bookings::School.find_by!(urn: urn).tap do |s|
      create :bookings_profile, school: s
    end
  end

  let :placement_date do
    create :bookings_placement_date, :unpublished,
      bookings_school: school,
      subject_specific: nil
  end

  describe '#new' do
    before { get new_schools_placement_date_date_limit_path placement_date }
    subject { response }

    it 'assigns the correct placement_date' do
      expect(assigns(:placement_date)).to eq placement_date
    end

    it 'renders the new template' do
      is_expected.to have_http_status :success
      is_expected.to render_template :new
    end
  end

  describe '#create' do
    let(:key) { Schools::PlacementDates::DateLimitForm.model_name.param_key }

    before do
      post schools_placement_date_date_limit_path(placement_date),
        params: params
    end

    subject { response }

    context 'with valid data' do
      let(:params) { { key => { max_bookings_count: 4 } } }
      it { is_expected.to redirect_to schools_placement_dates_path }
      it { expect(placement_date.reload.max_bookings_count).to eq 4 }
    end

    context 'with invalid data' do
      let(:params) { { key => { max_bookings_count: 0 } } }
      it { is_expected.to have_http_status :success }
      it { is_expected.to render_template :new }
    end
  end
end
