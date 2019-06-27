require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementRequests::CancellationsController, type: :request do
  include_context "logged in DfE user"

  let :school do
    Bookings::School.find_by!(urn: urn).tap do |s|
      s.subjects << FactoryBot.create_list(:bookings_subject, 5)
      FactoryBot.create(:bookings_profile, school: s)
    end
  end

  context '#new' do
    before do
      get "/schools/placement_requests/#{placement_request.id}/cancellation/new"
    end

    context 'when request already closed' do
      let :placement_request do
        FactoryBot.create :placement_request, :cancelled, school: school
      end

      it 'redirects to the placement_show path' do
        expect(response).to redirect_to \
          schools_placement_request_path(placement_request)
      end
    end

    context 'when request not already closed' do
      let :placement_request do
        FactoryBot.create :placement_request, school: school
      end

      it 'assigns the cancellation' do
        expect(assigns(:cancellation).reason).to eq \
          placement_request.build_school_cancellation.reason
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end
  end

  context '#create' do
    let :cancellation_params do
      { bookings_placement_request_cancellation: cancellation.attributes }
    end

    before do
      post "/schools/placement_requests/#{placement_request.id}/cancellation",
        params: cancellation_params
    end

    context 'when placement request already closed' do
      let :placement_request do
        FactoryBot.create :placement_request, :cancelled, school: school
      end

      let :cancellation do
        FactoryBot.build :cancellation, placement_request: placement_request
      end

      it 'redirects to the placement_show path' do
        expect(response).to redirect_to \
          schools_placement_request_path(placement_request)
      end
    end

    context 'when placement request not closed' do
      let :placement_request do
        FactoryBot.create :placement_request, school: school
      end

      context 'failure' do
        let :cancellation do
          placement_request.build_school_cancellation
        end

        it 'rerenders the new template' do
          expect(response).to render_template :new
        end

        it "doesn't create the rejection" do
          expect(placement_request.school_cancellation).not_to be_persisted
        end
      end

      context 'success' do
        let :cancellation do
          FactoryBot.build :cancellation,
            reason: "school's out for summer",
            placement_request: placement_request
        end

        it 'creates the cancellation' do
          expect(placement_request.school_cancellation.reason).to \
            eq "school's out for summer"
        end

        it 'redirects to the show action' do
          expect(response).to redirect_to \
            schools_placement_request_cancellation_path(placement_request)
        end
      end
    end
  end

  context '#edit' do
    before do
      get "/schools/placement_requests/#{placement_request.id}/cancellation/edit"
    end

    context 'when placement request already closed' do
      let :placement_request do
        FactoryBot.create :placement_request, :cancelled, school: school
      end

      it 'redirects to the placement_show path' do
        expect(response).to redirect_to \
          schools_placement_request_path(placement_request)
      end
    end

    context 'when request not already closed' do
      let :placement_request do
        FactoryBot.create \
          :placement_request, :with_school_cancellation, school: school
      end

      it 'assigns the cancellation' do
        expect(assigns(:cancellation).reason).to eq \
          placement_request.school_cancellation.reason
      end

      it 'renders the edit template' do
        expect(response).to render_template :edit
      end
    end
  end

  context '#update' do
    before do
      patch "/schools/placement_requests/#{placement_request.id}/cancellation",
        params: cancellation_params
    end

    let :cancellation_params do
      { bookings_placement_request_cancellation: cancellation.attributes }
    end

    context 'when placement request already closed' do
      let :placement_request do
        FactoryBot.create \
          :placement_request, :cancelled_by_school, school: school
      end

      let :cancellation do
        FactoryBot.build :cancellation,
          reason: "school's out for ever",
          placement_request: placement_request
      end

      it "doesn't update the rejection" do
        expect(placement_request.school_cancellation.reload.reason).not_to \
          eq "school's out for ever"
      end

      it 'redirects to the placement_show path' do
        expect(response).to redirect_to \
          schools_placement_request_path(placement_request)
      end
    end

    context 'when request not already closed' do
      let :placement_request do
        FactoryBot.create \
          :placement_request, :with_school_cancellation, school: school
      end

      context 'failure' do
        let :cancellation do
          FactoryBot.build :cancellation,
            reason: "",
            placement_request: placement_request
        end

        it 'rerenders the edit template' do
          expect(response).to render_template :edit
        end

        it "doesn't update the rejection" do
          expect(placement_request.school_cancellation.reload.reason).not_to \
            eq "school's out for ever"
        end
      end

      context 'success' do
        let :cancellation do
          FactoryBot.build :cancellation,
            reason: "school's out for ever",
            placement_request: placement_request
        end

        it 'updates the rejection' do
          expect(placement_request.school_cancellation.reload.reason).to \
            eq "school's out for ever"
        end

        it 'redirects to the show action' do
          expect(response).to redirect_to \
            schools_placement_request_cancellation_path(placement_request)
        end
      end
    end
  end
end
