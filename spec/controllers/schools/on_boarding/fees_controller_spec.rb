require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::OnBoarding::FeesController, type: :request do
  include_context "logged in DfE user"

  context '#new' do
    let! :school_profile do
      FactoryBot.create :school_profile,
        :with_dbs_requirement,
        :with_candidate_requirements_selection
    end
    let(:task_progress_on_boarding) { false }

    before do
      allow(Feature).to receive(:enabled?).with(:task_progress_on_boarding)
        .and_return(task_progress_on_boarding)
    end

    before do
      get '/schools/on_boarding/fees/new'
    end

    it 'assigns the model' do
      expect(assigns(:fees)).to eq Schools::OnBoarding::Fees.new(dbs_fees_specified: false)
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let! :school_profile do
      FactoryBot.create :school_profile,
        :with_dbs_requirement,
        :with_candidate_requirements_selection
    end

    let :params do
      { schools_on_boarding_fees: fees.attributes }
    end

    before do
      post '/schools/on_boarding/fees', params: params
    end

    context 'invalid' do
      let :fees do
        Schools::OnBoarding::Fees.new(selected_fees: %w[administration_fees none])
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.fees).not_to eq fees
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :fees do
        FactoryBot.build :fees
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.fees.attributes).to eq fees.attributes
      end

      it 'redirects to the correct_step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_administration_fee_path
      end

      context "when the task_progress_on_boarding feature is enabled" do
        let(:task_progress_on_boarding) { true }

        it 'redirects to the correct_step' do
          expect(response).to redirect_to \
            new_schools_on_boarding_administration_fee_path
        end
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/fees/edit'
    end

    it 'assigns the model' do
      expect(assigns(:fees)).to eq school_profile.fees
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
      { schools_on_boarding_fees: fees.attributes }
    end

    before do
      patch '/schools/on_boarding/fees', params: params
    end

    context 'invalid' do
      let :fees do
        Schools::OnBoarding::Fees.new(selected_fees: %w[administration_fees none])
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.fees).not_to eq fees
      end

      it 're-renders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :fees do
        FactoryBot.build :fees
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.fees).to eq fees
      end

      it 'redirects to the first selected fee' do
        expect(response).to \
          redirect_to new_schools_on_boarding_administration_fee_path
      end
    end
  end
end
