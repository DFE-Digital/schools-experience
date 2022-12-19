require "rails_helper"
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PrepopulateSchoolProfilesController, type: :request do
  include_context "logged in DfE user"
  include_context "stub role check api"

  describe "#create" do
    before do
      allow_any_instance_of(Schools::DFESignInAPI::RoleCheckedOrganisations).to \
        receive(:organisation_uuid_pairs).and_return \
          SecureRandom.uuid => prepopulate_from_school.urn,
          SecureRandom.uuid => @current_user_school.urn
    end

    let(:prepopulate_from_school) { create(:bookings_school, :with_school_profile, :onboarded) }
    let(:params) { { schools_prepopulate_school_profile: { prepopulate_from_urn: prepopulate_from_school.urn } } }

    subject { post(schools_prepopulate_school_profiles_path, params: params) }

    it "prepopulates the school profile" do
      is_expected.to redirect_to(schools_on_boarding_progress_path)

      follow_redirect!

      excluding_attributes = %w[id bookings_school_id created_at updated_at]
      expected_attributes = prepopulate_from_school.school_profile.attributes.without(excluding_attributes)
      expect(@current_user_school.school_profile).to have_attributes(expected_attributes)

      expect(response.body).to include("Your profile has been prepopulated")
    end
  end
end
