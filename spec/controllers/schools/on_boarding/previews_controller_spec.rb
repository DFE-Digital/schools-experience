require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::PreviewsController, type: :request do
  include_context "logged in DfE user"

  let! :early_years do
    FactoryBot.create :bookings_phase, :early_years
  end

  let! :primary do
    FactoryBot.create :bookings_phase, :primary
  end

  let! :secondary do
    FactoryBot.create :bookings_phase, :secondary
  end

  let! :college do
    FactoryBot.create :bookings_phase, :college
  end

  let! :school do
    FactoryBot.create :bookings_school
  end

  context '#show' do
    context 'when profile is not complete' do
      let! :school_profile do
        FactoryBot.create :school_profile, bookings_school: school
      end

      before do
        get '/schools/on_boarding/preview'
      end

      it 'redirects to the first outstanding step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_candidate_requirement_path
      end
    end

    context 'when profile is complete' do
      let! :school_profile do
        FactoryBot.create :school_profile,
          :completed,
          :with_only_early_years_phase,
          bookings_school: school
      end

      before do
        get '/schools/on_boarding/preview'
      end

      it 'sets up @school' do
        expect(assigns(:school).phase_ids).to \
          match_array [early_years, primary].map(&:id)

        expect(assigns(:school).subject_ids).to \
          match_array school_profile.subjects.map(&:id)
      end

      it 'sets up @presenter' do
        expect(assigns(:presenter)).to be_a Schools::OnBoarding::PreviewPresenter
      end

      it 'renders the show template' do
        expect(response).to render_template :show
      end
    end
  end
end
