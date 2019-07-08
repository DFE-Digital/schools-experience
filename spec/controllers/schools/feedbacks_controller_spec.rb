require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::FeedbacksController, type: :request do
  include_context "logged in DfE user"

  context '#new' do
    before do
      get '/schools/feedbacks/new'
    end

    it 'assigns the model' do
      expect(assigns(:feedback)).to be_a Schools::Feedback
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let :feedback_params do
      { schools_feedback: feedback.attributes }
    end

    before do
      post '/schools/feedbacks', params: feedback_params
    end

    context 'invalid' do
      let :feedback do
        Schools::Feedback.new
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end

      it 'does not save the feedback' do
        expect(Schools::Feedback.count).to be_zero
      end
    end

    context 'valid' do
      let :feedback do
        FactoryBot.build :schools_feedback
      end

      it 'redirects to the show action' do
        expect(response).to redirect_to \
          schools_feedback_path Schools::Feedback.last
      end
    end
  end

  context '#show' do
    let :feedback do
      FactoryBot.create :schools_feedback
    end

    before do
      get schools_feedback_path(feedback)
    end

    it 'renders the show template' do
      expect(response).to render_template :show
    end
  end
end
