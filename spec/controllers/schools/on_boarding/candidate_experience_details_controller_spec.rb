require 'rails_helper'

require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::OnBoarding::CandidateExperienceDetailsController, type: :request do
  include_context "logged in DfE user"
  include_context 'with phases'

  context '#new' do
    let! :school_profile do
      FactoryBot.create \
        :school_profile,
        :with_candidate_requirement,
        :with_fees,
        :with_administration_fee,
        :with_dbs_fee,
        :with_other_fee,
        :with_only_early_years_phase,
        :with_key_stage_list,
        :with_specialism
    end

    before do
      get '/schools/on_boarding/candidate_experience_detail/new'
    end

    it 'assigns the model' do
      expect(assigns(:candidate_experience_detail)).to \
        eq Schools::OnBoarding::CandidateExperienceDetail.new
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let! :school_profile do
      FactoryBot.create \
        :school_profile,
        :with_candidate_requirement,
        :with_fees,
        :with_administration_fee,
        :with_dbs_fee,
        :with_other_fee,
        :with_only_early_years_phase,
        :with_key_stage_list,
        :with_specialism
    end

    let :params do
      {
        schools_on_boarding_candidate_experience_detail: \
          candidate_experience_detail.attributes
      }
    end

    before do
      post '/schools/on_boarding/candidate_experience_detail/', params: params
    end

    context 'invalid' do
      let :candidate_experience_detail do
        Schools::OnBoarding::CandidateExperienceDetail.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.candidate_experience_detail.attributes).to \
          eq candidate_experience_detail.attributes
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :candidate_experience_detail do
        FactoryBot.build :candidate_experience_detail
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.candidate_experience_detail).to \
          eq candidate_experience_detail
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_availability_preference_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/candidate_experience_detail/edit'
    end

    it 'assigns the model' do
      expect(assigns(:candidate_experience_detail)).to \
        eq school_profile.candidate_experience_detail
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
        schools_on_boarding_candidate_experience_detail: \
          candidate_experience_detail.attributes
      }
    end

    before do
      patch '/schools/on_boarding/candidate_experience_detail/', params: params
    end

    context 'invalid' do
      let :candidate_experience_detail do
        Schools::OnBoarding::CandidateExperienceDetail.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.candidate_experience_detail).not_to \
          eq candidate_experience_detail
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :candidate_experience_detail do
        FactoryBot.build \
          :candidate_experience_detail, business_dress: false
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.candidate_experience_detail).to \
          eq candidate_experience_detail
      end

      it 'redirects to the school_profile' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
