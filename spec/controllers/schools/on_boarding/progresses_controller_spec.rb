require "rails_helper"
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::OnBoarding::ProgressesController, type: :request do
  include_context "logged in DfE user"

  context "#show" do
    let!(:school_profile) { create(:school_profile, :with_dbs_requirement) }

    before { get schools_on_boarding_progress_path }

    it "assigns the model" do
      expect(assigns(:wizard)).to be_an_instance_of(Schools::OnBoarding::Wizard)
      expect(assigns(:wizard).school_profile).to eq(school_profile)
    end

    it "renders the show template" do
      expect(response).to render_template(:show)
    end
  end
end
