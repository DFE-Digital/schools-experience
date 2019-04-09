require 'rails_helper'

describe Schools::OnBoarding::AdminContactsController, type: :request do
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
      :with_specialism,
      :with_candidate_experience_detail,
      :with_experience_outline
  end

  context '#new' do
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
end
