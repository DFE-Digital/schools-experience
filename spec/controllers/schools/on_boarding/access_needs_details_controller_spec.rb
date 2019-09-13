require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::AccessNeedsDetailsController, type: :request do
  include_context "logged in DfE user"

  let! :school_profile do
    FactoryBot.create \
      :school_profile,
      :with_dbs_requirement,
      :with_candidate_requirement,
      :with_fees,
      :with_administration_fee,
      :with_dbs_fee,
      :with_other_fee,
      :with_only_early_years_phase,
      :with_key_stage_list,
      :with_description,
      :with_candidate_experience_detail,
      :with_access_needs_support
  end

  context '#new' do
    before do
      get '/schools/on_boarding/access_needs_detail/new'
    end

    it 'assigns the model' do
      expect(assigns(:access_needs_detail)).to \
        eq Schools::OnBoarding::AccessNeedsDetail.new.tap(&:add_default_copy!)
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let :params do
      {
        schools_on_boarding_access_needs_detail: access_needs_detail.attributes
      }
    end

    before do
      post '/schools/on_boarding/access_needs_detail/', params: params
    end

    context 'invalid' do
      let :access_needs_detail do
        Schools::OnBoarding::AccessNeedsDetail.new
      end

      it 'doesnt update the school profile' do
        expect(school_profile.reload.access_needs_detail).to \
          eq Schools::OnBoarding::AccessNeedsDetail.new
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :access_needs_detail do
        FactoryBot.build :access_needs_detail
      end

      it 'updates the school profile' do
        expect(school_profile.reload.access_needs_detail).to \
          eq access_needs_detail
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_experience_outline_path
      end
    end
  end
end
