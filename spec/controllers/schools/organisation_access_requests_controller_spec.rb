require "rails_helper"
require Rails.root.join("spec", "controllers", "schools", "session_context")

RSpec.describe Schools::OrganisationAccessRequestsController, type: :request do
  include_context "logged in DfE user"

  subject { page_request && response }

  before do
    allow(Rails.application.config.x).to \
      receive(:dfe_sign_in_request_organisation_url) \
        .and_return dsi_org_access_url
  end

  let(:dsi_org_access_url) { "https://dsi.education.gov.uk/request/access" }

  describe "#show" do
    let(:page_request) { get schools_organisation_access_request_path }

    it { is_expected.to have_http_status :success }
    it { is_expected.to render_template "show" }
    it { expect(subject.body).to match dsi_org_access_url }

    context "with emptpy org access url" do
      let(:dsi_org_access_url) { {} }

      it { is_expected.to have_http_status :success }
      it { is_expected.to render_template "show" }
      it { expect(subject.body).to match "Contact your school" }
    end
  end
end
