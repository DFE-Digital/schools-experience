require 'rails_helper'

describe Candidates::FeedbacksController, type: :request do
  context '#new' do
    before do
      get '/candidates/feedbacks/new'
    end

    it 'assigns the model' do
      expect(assigns(:feedback)).to be_a Candidates::Feedback
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let :feedback_params do
      { candidates_feedback: feedback.attributes }
    end

    before do
      post '/candidates/feedbacks', params: feedback_params
    end

    context 'invalid' do
      let :feedback do
        Candidates::Feedback.new
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end

      it 'does not save the feedback' do
        expect(Candidates::Feedback.count).to be_zero
      end
    end

    context 'valid' do
      let :feedback do
        FactoryBot.build :candidates_feedback
      end

      it 'redirects to the show action' do
        expect(response).to redirect_to \
          candidates_feedback_path Candidates::Feedback.last
      end
    end
  end

  context '#show' do
    let :feedback do
      FactoryBot.create :candidates_feedback
    end

    before do
      get candidates_feedback_path(feedback)
    end

    it 'renders the show template' do
      expect(response).to render_template :show
    end
  end
end
