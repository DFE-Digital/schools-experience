require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementDates::ConfigurationsController, type: :request do
  include_context "logged in DfE user"

  let! :school do
    Bookings::School.find_by!(urn: urn).tap do |s|
      create :bookings_profile, school: s
    end
  end

  let! :placement_date do
    create :bookings_placement_date, bookings_school: school, published_at: nil
  end

  context '#new' do
    before do
      get "/schools/placement_dates/#{placement_date.id}/configuration/new"
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
        schools_placement_dates_configuration_form: {
          max_bookings_count: max_bookings_count,
          has_limited_availability: has_limited_availability,
          available_for_all_subjects: available_for_all_subjects
        }
      }
    end

    before do
      post "/schools/placement_dates/#{placement_date.id}/configuration",
        params: params
    end

    context 'invalid' do
      let :max_bookings_count do
        0
      end

      let :has_limited_availability do
        true
      end

      let :available_for_all_subjects do
        false
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end

      it "doesn't update the placement_date" do
        expect(placement_date.max_bookings_count).to be nil
      end
    end

    context 'valid' do
      context 'when not available_for_all_subjects' do
        let :max_bookings_count do
          1
        end

        let :has_limited_availability do
          true
        end

        let :available_for_all_subjects do
          false
        end

        it 'updates the placement date' do
          expect(placement_date.reload.max_bookings_count).to eq max_bookings_count
          expect(placement_date.reload.has_limited_availability?).to eq has_limited_availability
        end

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            new_schools_placement_date_subject_selection_path placement_date
        end
      end

      context "when is available_for_all_subjects" do
        let :max_bookings_count do
          nil
        end

        let :has_limited_availability do
          false
        end

        let :available_for_all_subjects do
          true
        end

        it 'updates the placement date' do
          expect(placement_date.reload.max_bookings_count).to eq max_bookings_count
          expect(placement_date.reload.capped?).to eq has_limited_availability
        end

        it 'redirects to the dashboard' do
          expect(response).to redirect_to schools_placement_dates_path
        end
      end
    end
  end
end
