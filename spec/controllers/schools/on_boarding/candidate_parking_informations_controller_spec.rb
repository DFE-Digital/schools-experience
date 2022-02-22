require 'rails_helper'

require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::OnBoarding::CandidateParkingInformationsController, type: :request do
  include_context "logged in DfE user"

  context '#new' do
    let! :school_profile do
      FactoryBot.create \
        :school_profile,
        :with_dbs_requirement,
        :with_candidate_requirements_selection,
        :with_fees,
        :with_administration_fee,
        :with_dbs_fee,
        :with_other_fee,
        :with_only_early_years_phase,
        :with_key_stage_list,
        :with_description,
        :with_candidate_dress_code
    end

    before do
      get new_schools_on_boarding_candidate_parking_information_path
    end

    it 'assigns the model' do
      expect(assigns(:candidate_parking_information)).to \
        eq Schools::OnBoarding::CandidateParkingInformation.new
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let! :school_profile do
      FactoryBot.create \
        :school_profile,
        :with_dbs_requirement,
        :with_candidate_requirements_selection,
        :with_fees,
        :with_administration_fee,
        :with_dbs_fee,
        :with_other_fee,
        :with_only_early_years_phase,
        :with_key_stage_list,
        :with_description,
        :with_candidate_dress_code
    end

    let :params do
      {
        schools_on_boarding_candidate_parking_information: \
          candidate_parking_information.attributes
      }
    end

    before do
      post schools_on_boarding_candidate_parking_information_path, params: params
    end

    context 'invalid' do
      let :candidate_parking_information do
        Schools::OnBoarding::CandidateParkingInformation.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.candidate_parking_information.attributes).to \
          eq candidate_parking_information.attributes
      end

      it 're-renders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :candidate_parking_information do
        FactoryBot.build :candidate_parking_information
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.candidate_parking_information).to \
          eq candidate_parking_information
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_candidate_experience_schedule_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get edit_schools_on_boarding_candidate_parking_information_path
    end

    it 'assigns the model' do
      expect(assigns(:candidate_parking_information)).to \
        eq school_profile.candidate_parking_information
    end

    it 'renders the edit template' do
      expect(response).to render_template :edit
    end
  end

  context '#update' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    let :params do
      {
        schools_on_boarding_candidate_parking_information: \
          candidate_parking_information.attributes
      }
    end

    before do
      patch schools_on_boarding_candidate_parking_information_path, params: params
    end

    context 'invalid' do
      let :candidate_parking_information do
        Schools::OnBoarding::CandidateParkingInformation.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.candidate_parking_information).not_to \
          eq candidate_parking_information
      end

      it 're-renders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :candidate_parking_information do
        FactoryBot.build \
          :candidate_parking_information
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.candidate_parking_information).to \
          eq candidate_parking_information
      end

      it 'redirects to the school_profile' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
