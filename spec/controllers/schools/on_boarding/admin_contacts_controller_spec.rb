require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::AdminContactsController, type: :request do
  include_context "logged in DfE user"

  context '#new' do
    let! :school_profile do
      FactoryBot.create \
        :school_profile,
        :with_dbs_requirement,
        :with_candidate_requirements_choice,
        :with_candidate_requirements_selection,
        :with_fees,
        :with_administration_fee,
        :with_dbs_fee,
        :with_other_fee,
        :with_only_early_years_phase,
        :with_key_stage_list,
        :with_description,
        :with_candidate_experience_detail,
        :with_access_needs_support,
        :with_access_needs_detail,
        :with_disability_confident,
        :with_access_needs_policy,
        :with_experience_outline
    end

    before do
      get '/schools/on_boarding/admin_contact/new'
    end

    it 'assigns the model' do
      expect(assigns(:admin_contact)).to \
        eq Schools::OnBoarding::AdminContact.new
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
        :with_candidate_requirements_choice,
        :with_candidate_requirements_selection,
        :with_fees,
        :with_administration_fee,
        :with_dbs_fee,
        :with_other_fee,
        :with_only_early_years_phase,
        :with_key_stage_list,
        :with_description,
        :with_candidate_experience_detail,
        :with_access_needs_support,
        :with_access_needs_detail,
        :with_disability_confident,
        :with_access_needs_policy,
        :with_experience_outline
    end

    let :params do
      {
        schools_on_boarding_admin_contact: admin_contact.attributes
      }
    end

    before do
      post '/schools/on_boarding/admin_contact', params: params
    end

    context 'invalid' do
      let :admin_contact do
        Schools::OnBoarding::AdminContact.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.admin_contact).to eq admin_contact
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :admin_contact do
        FactoryBot.build :admin_contact
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.admin_contact).to eq admin_contact
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/admin_contact/edit'
    end

    it 'assigns the model' do
      expect(assigns(:admin_contact)).to eq school_profile.admin_contact
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
        schools_on_boarding_admin_contact: admin_contact.attributes
      }
    end

    before do
      patch '/schools/on_boarding/admin_contact', params: params
    end

    context 'invalid' do
      let :admin_contact do
        Schools::OnBoarding::AdminContact.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.admin_contact).not_to eq admin_contact
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :admin_contact do
        FactoryBot.build :admin_contact
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.admin_contact).to eq admin_contact
      end

      it 'redirects to the school_profile' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
