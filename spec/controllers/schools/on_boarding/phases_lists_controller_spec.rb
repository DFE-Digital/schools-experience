require 'rails_helper'

require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::OnBoarding::PhasesListsController, type: :request do
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
        :with_other_fee
    end

    before do
      get '/schools/on_boarding/phases_list/new'
    end

    it 'assigns the model' do
      expect(assigns(:phases_list)).to eq Schools::OnBoarding::PhasesList.new
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
        :with_other_fee
    end

    let :params do
      { schools_on_boarding_phases_list: phases_list.attributes }
    end

    before do
      post '/schools/on_boarding/phases_list', params: params
    end

    context 'invalid' do
      let :phases_list do
        Schools::OnBoarding::PhasesList.new
      end

      it "doesn't update the school profile" do
        expect(school_profile.reload.phases_list).to eq phases_list
      end

      it 'rerenders the new form' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :phases_list do
        FactoryBot.build :phases_list
      end

      it 'updates the school profile' do
        expect(school_profile.reload.phases_list).to eq phases_list
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_key_stage_list_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/phases_list/edit'
    end

    it 'assigns the model' do
      expect(assigns(:phases_list)).to eq school_profile.phases_list
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
        schools_on_boarding_phases_list: phases_list.attributes
      }
    end

    before do
      patch '/schools/on_boarding/phases_list', params: params
    end

    context 'invalid' do
      let :phases_list do
        Schools::OnBoarding::PhasesList.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.phases_list).not_to eq phases_list
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :phases_list do
        FactoryBot.build \
          :phases_list, primary: !school_profile.phases_list.primary
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.phases_list).to eq phases_list
      end

      it 'redirects to the school_profile' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
