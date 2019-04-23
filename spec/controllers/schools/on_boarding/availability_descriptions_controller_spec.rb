require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::AvailabilityDescriptionsController, type: :request do
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
        :with_specialism,
        :with_candidate_experience_detail,
        :with_availability_preference
    end

    before do
      get '/schools/on_boarding/availability_description/new'
    end

    it 'assings the model' do
      expect(assigns(:availability_description)).to \
        eq Schools::OnBoarding::AvailabilityDescription.new
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
        :with_specialism,
        :with_candidate_experience_detail,
        :with_availability_preference
    end

    let :params do
      {
        schools_on_boarding_availability_description: \
          availability_description.attributes
      }
    end

    before do
      post '/schools/on_boarding/availability_description', params: params
    end

    context 'invalid' do
      let :availability_description do
        Schools::OnBoarding::AvailabilityDescription.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.availability_description).to \
          eq availability_description
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :availability_description do
        FactoryBot.build :availability_description
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.availability_description).to \
          eq availability_description
      end

      it 'redirects to the next_step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_experience_outline_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/availability_description/edit'
    end

    it 'assigns the model' do
      expect(assigns(:availability_description)).to \
        eq school_profile.availability_description
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
        schools_on_boarding_availability_description: \
          availability_description.attributes
      }
    end

    before do
      patch '/schools/on_boarding/availability_description', params: params
    end

    context 'invalid' do
      let :availability_description do
        Schools::OnBoarding::AvailabilityDescription.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.availability_description).not_to \
          eq availability_description
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :availability_description do
        FactoryBot.build :availability_description, description: 'Updated!'
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.availability_description).to \
          eq availability_description
      end

      it 'redirects to the school_profile' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
