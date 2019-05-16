require 'rails_helper'

describe Candidates::PlacementRequests::CancellationsController, type: :request do
  context '#new' do
    before do
      get "/candidates/placement_requests/#{placement_request.token}/cancellation/new"
    end

    context 'when request already closed' do
      let :placement_request do
        FactoryBot.create :placement_request, :cancelled
      end

      it 'redirects to the show action' do
        expect(response).to redirect_to \
          candidates_placement_request_cancellation_path(placement_request.token)
      end
    end

    context 'when request not already closed' do
      let :placement_request do
        FactoryBot.create :placement_request
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
      post \
        "/candidates/placement_requests/#{placement_request.token}/cancellation/",
        params: cancellation_params
    end

    context 'when request already closed' do
      let :placement_request do
        FactoryBot.create :placement_request, :cancelled
      end

      let :cancellation do
        FactoryBot.build :cancellation, \
          reason: 'Some other reason',
          placement_request: nil
      end

      it 'doesnt create the placement request' do
        expect(placement_request.cancellation.reason).not_to \
          eq cancellation.reason
      end

      xit 'does not notify the school'

      it 'redirects to the show action' do
        expect(response).to redirect_to \
          candidates_placement_request_cancellation_path(placement_request.token)
      end
    end

    context 'when request not already closed' do
      let :placement_request do
        FactoryBot.create :placement_request
      end

      context 'invalid' do
        let :cancellation do
          Bookings::PlacementRequest::Cancellation.new
        end

        xit 'does not notify the school'

        it 'does not cancel the placement request' do
          expect(placement_request).not_to be_closed
        end

        it 'rerenders the new template' do
          expect(response).to render_template :new
        end
      end

      context 'valid' do
        let :cancellation do
          FactoryBot.build :cancellation, placement_request: placement_request
        end

        xit 'notifies the school'

        it 'cancels the placement request' do
          expect(placement_request).to be_closed
        end

        it 'redirects to the show action' do
          # need to make sure the show action isn't accessable by id for security
          expect(response).to redirect_to \
            candidates_placement_request_cancellation_path(placement_request.token)
        end
      end
    end
  end

  context '#show' do
    let :placement_request do
      FactoryBot.create :placement_request, :cancelled
    end

    before do
      get \
        "/candidates/placement_requests/#{placement_request.token}/cancellation"
    end

    it 'renders the show template' do
      expect(response).to render_template :show
    end
  end
end
