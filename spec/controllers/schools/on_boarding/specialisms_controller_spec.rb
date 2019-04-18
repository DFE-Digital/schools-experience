require 'rails_helper'

require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::OnBoarding::SpecialismsController, type: :request do
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
        :with_key_stage_list
    end

    before do
      get '/schools/on_boarding/specialism/new'
    end

    it 'assigns the model' do
      expect(assigns(:specialism)).to eq Schools::OnBoarding::Specialism.new
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
        :with_key_stage_list
    end

    let :params do
      { schools_on_boarding_specialism: specialism.attributes }
    end

    before do
      post '/schools/on_boarding/specialism', params: params
    end

    context 'invalid' do
      let :specialism do
        Schools::OnBoarding::Specialism.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.specialism).to eq specialism
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :specialism do
        FactoryBot.build :specialism
      end

      it 'updates the school profile' do
        expect(school_profile.reload.specialism).to eq specialism
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_candidate_experience_detail_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/specialism/edit'
    end

    it 'assigns the model' do
      expect(assigns(:specialism)).to eq school_profile.specialism
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
        schools_on_boarding_specialism: specialism.attributes
      }
    end

    before do
      patch '/schools/on_boarding/specialism', params: params
    end

    context 'invalid' do
      let :specialism do
        Schools::OnBoarding::Specialism.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.specialism).not_to eq specialism
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :specialism do
        FactoryBot.build :specialism, has_specialism: false
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.specialism).to eq specialism
      end

      it 'redirects to the school_profile' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
