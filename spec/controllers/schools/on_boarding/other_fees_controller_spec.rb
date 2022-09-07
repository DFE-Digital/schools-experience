require 'rails_helper'

require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::OnBoarding::OtherFeesController, type: :request do
  include_context "logged in DfE user"

  let! :school_profile do
    FactoryBot.create \
      :school_profile,
      :with_dbs_requirement,
      :with_candidate_requirements_selection,
      :with_fees,
      :with_administration_fee,
      :with_dbs_fee
  end
  let(:task_progress_on_boarding) { false }

  before do
    allow(Feature).to receive(:enabled?).with(:task_progress_on_boarding)
      .and_return(task_progress_on_boarding)
  end

  context '#new' do
    before do
      get '/schools/on_boarding/other_fee/new'
    end

    it 'assigns the model' do
      expect(assigns(:other_fee)).to eq Schools::OnBoarding::OtherFee.new
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
      get '/schools/on_boarding/other_fee/new'
    end

    it 'assigns the model' do
      expect(assigns(:other_fee)).to \
        eq school_profile.other_fee
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let :params do
      { schools_on_boarding_other_fee: other_fee.attributes }
    end

    before do
      post '/schools/on_boarding/other_fee', params: params
    end

    context 'invalid' do
      let :other_fee do
        Schools::OnBoarding::OtherFee.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.other_fee).to eq other_fee
      end

      it "doesn't mark the step as complete" do
        expect(school_profile.reload.other_fee_step_completed).to_not be true
      end

      it 'rerenders the new form' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :other_fee do
        FactoryBot.build :other_fee
      end

      it "updates the school_profile" do
        expect(school_profile.reload.other_fee).to eq other_fee
      end

      it 'marks the step as complete' do
        expect(school_profile.reload.other_fee_step_completed).to be true
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to new_schools_on_boarding_phases_list_path
      end

      context "when the task_progress_on_boarding feature is enabled" do
        let(:task_progress_on_boarding) { true }

        it 'redirects to the progress page' do
          expect(response).to redirect_to schools_on_boarding_progress_path
        end
      end
    end
  end
end
