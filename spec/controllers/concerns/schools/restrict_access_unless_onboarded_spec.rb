require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::RestrictAccessUnlessOnboarded, type: :request do
  include_context "logged in DfE user"
  subject { Schools::ConfirmedBookings::CancellationsController }

  context 'when the school is not onboarded' do
    before { get "/schools/placement_requests/1/cancellation/new" }

    specify 'controller should include the restrict access module' do
      expect(subject.ancestors).to include(Schools::RestrictAccessUnlessOnboarded)
    end

    specify 'should redirect to the dashboard' do
      expect(subject).to redirect_to(schools_dashboard_path)
    end
  end
end
