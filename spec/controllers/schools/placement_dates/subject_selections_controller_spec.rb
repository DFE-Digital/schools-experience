require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementDates::SubjectSelectionsController, type: :request do
  let! :school do
    create \
      :bookings_school,
      :onboarded,
      :with_subjects,
      urn: urn,
      subject_count: 3
  end

  let! :placement_date do
    create \
      :bookings_placement_date,
      bookings_school: school,
      max_bookings_count: 5
  end

  include_context "logged in DfE user"

  context '#new' do
    before do
      get "/schools/placement_dates/#{placement_date.id}/subject_selection/new"
    end

    it 'assigns the correct placement_date' do
      expect(assigns(:placement_date)).to eq placement_date
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let :params do
      {
        schools_placement_dates_subject_selection: { subject_ids: subject_ids }
      }
    end

    before do
      post "/schools/placement_dates/#{placement_date.id}/subject_selection",
        params: params

      placement_date.reload
    end

    context 'invalid' do
      let :subject_ids do
        []
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :subject_ids do
        school.subject_ids.first 2
      end

      it 'sets the subjects' do
        expect(placement_date).to be_subject_specific
        expect(placement_date.subjects).to match_array school.subjects.first(2)
      end

      it 'redirects to placement dates index' do
        expect(response).to redirect_to schools_placement_dates_path
      end
    end
  end
end
