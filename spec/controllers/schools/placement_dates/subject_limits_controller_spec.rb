require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementDates::SubjectLimitsController, type: :request do
  include_context "logged in DfE user"

  let :school do
    Bookings::School.find_by!(urn: urn).tap do |s|
      s.subjects = [create(:bookings_subject)]
      create :bookings_profile, school: s
    end
  end

  let(:subject_id) { school.subjects.first.id }

  let :placement_date do
    create :bookings_placement_date, :unpublished, :subject_specific,
      bookings_school: school,
      subject_ids: [subject_id]
  end

  describe '#new' do
    before { get new_schools_placement_date_subject_limit_path placement_date }
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
    let(:key) { Schools::PlacementDates::SubjectLimitForm.model_name.param_key }
    let(:attrname) { :"max_bookings_count_for_subject_#{subject_id}" }
    let(:date_subject) { placement_date.placement_date_subjects.first }

    before do
      post schools_placement_date_subject_limit_path(placement_date),
        params: params
    end

    subject { response }

    context 'with valid data' do
      let(:params) { { key => { attrname => 4 } } }
      it { is_expected.to redirect_to schools_placement_dates_path }
      it do
        expect(date_subject.reload).to have_attributes \
          bookings_subject_id: subject_id,
          max_bookings_count: 4
      end
    end

    context 'with invalid data' do
      let(:params) { { key => { attrname => 0 } } }
      it { is_expected.to have_http_status :success }
      it { is_expected.to render_template :new }
    end
  end
end
