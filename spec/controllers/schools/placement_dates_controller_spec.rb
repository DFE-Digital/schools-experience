require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementDatesController, type: :request do
  include_context "logged in DfE user"

  let! :school do
    Bookings::School.find_by!(urn: urn).tap do |s|
      create :bookings_profile, school: s
    end
  end

  describe '#create' do
    let(:base_params) do
      {
        bookings_placement_date: {
          date: 2.weeks.from_now.strftime('%Y-%m-%d'),
          duration: 1,
          active: true,
          virtual: false,
        }
      }
    end

    subject { post "/schools/placement_dates", params: params }
    let(:placement_date) { Bookings::PlacementDate.last }

    describe 'setting supports_subjects' do
      let(:option) { false }
      context "when supports_subjects hasn't been set" do
        let(:params) do
          base_params.deep_merge(bookings_placement_date: {})
        end

        context "when the school has only primary" do
          before do
            Bookings::School.find_by!(urn: urn).phases << create(:bookings_phase, :primary)
            school.update(enabled: false)
          end

          before { subject }

          specify 'supports_subjects should be set to false' do
            expect(placement_date.supports_subjects).to be false
          end

          it "enables the school" do
            expect(school.reload.enabled?).to be true
          end

          it "publishes the placement date" do
            expect(placement_date.reload.published_at).to_not be_nil
            expect(placement_date.reload.active).to be true
          end

          it 'redirects to the placement dates index page' do
            expect(subject).to redirect_to(schools_placement_dates_path)
          end
        end

        context "when the school has secondary or college" do
          before do
            Bookings::School.find_by!(urn: urn).phases << create(:bookings_phase, :secondary)
          end

          before { subject }

          specify 'supports_subjects should be set to true' do
            expect(placement_date.supports_subjects).to be true
          end
        end
      end
    end
  end

  context '#edit' do
    let :placement_date do
      create :bookings_placement_date, bookings_school: school
    end

    before do
      get "/schools/placement_dates/#{placement_date.id}/edit"
    end

    it 'assigns the placement date' do
      expect(assigns(:placement_date)).to eq placement_date
    end

    it 'renders the edit template' do
      expect(response).to render_template :edit
    end
  end

  context '#update' do
    let :placement_date do
      create :bookings_placement_date, bookings_school: school
    end

    let :params do
      { bookings_placement_date: placement_date.attributes }
    end

    context 'invalid' do
      before do
        placement_date.duration = nil
        patch "/schools/placement_dates/#{placement_date.id}/", params: params
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :duration do
        placement_date.duration + 1
      end

      before do
        placement_date.duration = duration
        patch "/schools/placement_dates/#{placement_date.id}/", params: params
      end

      it 'updates the placement date' do
        expect(placement_date.reload.duration).to eq duration
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          "http://www.example.com/schools/placement_dates/#{placement_date.id}/configuration/new"
      end
    end
  end

  context '#close' do
    let(:placement_date) { create :bookings_placement_date, :active, bookings_school: school }

    context 'when confirmed' do
      let(:params) { { schools_placement_dates_close_confirmation_form: { confirmed: true } } }

      it 'closes the date and redirects to the index page' do
        post schools_placement_date_close_path(placement_date.id), params: params

        expect(placement_date.reload.active).to be false
        expect(response).to redirect_to schools_placement_dates_path
      end
    end

    context 'when not confirmed' do
      let(:params) { { schools_placement_dates_close_confirmation_form: { confirmed: false } } }

      it 'does not close the date and redirects to the index page' do
        post schools_placement_date_close_path(placement_date.id), params: params

        expect(placement_date.reload.active).to be true
        expect(response).to redirect_to schools_placement_dates_path
      end
    end
  end
end
