require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::AdministrationFeesController, type: :request do
  include_context "logged in DfE user"

  let! :school_profile do
    FactoryBot.create :school_profile,
      :with_dbs_requirement,
      :with_candidate_requirements_selection,
      :with_fees
  end
  let(:task_progress_on_boarding) { false }

  before do
    allow(Feature).to receive(:enabled?).with(:task_progress_on_boarding)
      .and_return(task_progress_on_boarding)
  end

  context '#new' do
    before do
      get '/schools/on_boarding/administration_fee/new'
    end

    it 'assigns the model' do
      expect(assigns(:administration_fee)).to eq \
        Schools::OnBoarding::AdministrationFee.new
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/administration_fee/edit'
    end

    it 'assigns the model' do
      expect(assigns(:administration_fee)).to \
        eq school_profile.administration_fee
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let :params do
      { schools_on_boarding_administration_fee: administration_fee.attributes }
    end

    before do
      post '/schools/on_boarding/administration_fee', params: params
    end

    context 'invalid' do
      let :administration_fee do
        Schools::OnBoarding::AdministrationFee.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.administration_fee).to eq \
          administration_fee
      end

      it "doesn't marks the step as complete" do
        expect(school_profile.reload.administration_fee_step_completed).to_not be true
      end

      it 'rerenders the new form' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :administration_fee do
        FactoryBot.build :administration_fee
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.administration_fee).to eq \
          administration_fee
      end

      it 'marks the step as complete' do
        expect(school_profile.reload.administration_fee_step_completed).to be true
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to new_schools_on_boarding_dbs_fee_path
      end

      context "when the task_progress_on_boarding feature is enabled" do
        let(:task_progress_on_boarding) { true }

        it 'redirects to the next step' do
          expect(response).to redirect_to new_schools_on_boarding_dbs_fee_path
        end
      end
    end
  end
end
