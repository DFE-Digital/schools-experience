require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementDates::SubjectSpecificsController, type: :request do
  include_context "logged in DfE user"

  let! :school do
    Bookings::School.find_by!(urn: urn).tap do |s|
      create :bookings_profile, school: s
    end
  end

  let :placement_date do
    create :bookings_placement_date,
      :unpublished,
      bookings_school: school,
      subject_specific: nil
  end

  context '#new' do
    before do
      get "/schools/placement_dates/#{placement_date.id}/subject_specific/new"
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
        schools_placement_dates_subject_specific_form: {
          available_for_all_subjects: available_for_all_subjects
        }
      }
    end

    before do
      post "/schools/placement_dates/#{placement_date.id}/subject_specific",
        params: params
    end

    context 'invalid' do
      let :available_for_all_subjects do
        ''
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end

      it "doesn't update the placement_date" do
        expect(placement_date.subject_specific).to be_nil
      end
    end

    context 'valid' do
      context 'when not available_for_all_subjects' do
        let :available_for_all_subjects do
          false
        end

        it 'updates the placement date' do
          expect(placement_date.reload.subject_specific).to eq true
        end

        it "publishes the date" do
          expect(placement_date.reload).not_to be_published
        end

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            new_schools_placement_date_subject_selection_path placement_date
        end
      end

      context "when is available_for_all_subjects" do
        let :available_for_all_subjects do
          true
        end

        it 'updates the placement date' do
          expect(placement_date.reload.subject_specific).to eql false
        end

        it "publishes the date" do
          expect(placement_date.reload).to be_published
        end

        it 'redirects to the dashboard' do
          expect(response).to redirect_to schools_placement_dates_path
        end
      end

      context "when available_for_all_subjects and capped" do
        let :placement_date do
          create :bookings_placement_date,
            :unpublished, :capped,
            max_bookings_count: nil,
            bookings_school: school,
            subject_specific: nil
        end

        let :available_for_all_subjects do
          true
        end

        it 'updates the placement date' do
          expect(placement_date.reload.subject_specific).to eql false
        end

        it "does not publish the date" do
          expect(placement_date.reload).not_to be_published
        end

        it 'redirects to the dashboard' do
          expect(response).to redirect_to \
            new_schools_placement_date_date_limit_path(placement_date)
        end
      end
    end
  end
end
