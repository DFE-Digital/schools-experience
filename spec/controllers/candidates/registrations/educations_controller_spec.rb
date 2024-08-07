require 'rails_helper'

describe Candidates::Registrations::EducationsController, type: :request do
  include_context 'Stubbed current_registration'
  include_context "Degree subject autocomplete enabled"

  let :registration_session do
    FactoryBot.build :registration_session, with: %i[
      personal_information
      contact_information
    ]
  end
  let!(:school) { create(:bookings_school, urn: 11_048) }

  context '#new' do
    context 'without existing education in session' do
      before do
        get '/candidates/schools/11048/registrations/education/new'
      end

      it 'assigns the model with empty attributes' do
        expect(assigns(:education).attributes).to eq \
          Candidates::Registrations::Education.new.attributes
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'with existing education in session' do
      let :education do
        FactoryBot.build :education
      end

      before do
        registration_session.save education
      end

      before do
        get '/candidates/schools/11048/registrations/education/new'
      end

      it 'assigns the model with existing attributes' do
        expect(assigns(:education).attributes.except('created_at')).to \
          eq education.attributes.except('created_at')
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end
  end

  context '#create' do
    let :education_params do
      { candidates_registrations_education: education.attributes }
    end

    before do
      post '/candidates/schools/11048/registrations/education',
        params: education_params
    end

    context 'invalid' do
      let :education do
        Candidates::Registrations::Education.new
      end

      it 'doesnt modify the session' do
        expect { registration_session.education }.to raise_error \
          Candidates::Registrations::RegistrationSession::StepNotFound
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :education do
        FactoryBot.build :education
      end

      it 'store the education in the session' do
        expect(registration_session.education).to eq_model education
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          '/candidates/schools/11048/registrations/teaching_preference/new'
      end
    end
  end

  context '#edit' do
    let :education do
      FactoryBot.build :education
    end

    before do
      registration_session.save education
    end

    before do
      get '/candidates/schools/11048/registrations/education/edit'
    end

    it 'assigns the model with existing attributes' do
      expect(assigns(:education).attributes).to eq education.attributes
    end

    it 'renders the edit template' do
      expect(response).to render_template :edit
    end
  end

  context '#update' do
    let :existing_education do
      FactoryBot.build :education
    end

    before do
      registration_session.save existing_education
    end

    let :education_params do
      { candidates_registrations_education: education.attributes }
    end

    context 'invalid' do
      before do
        patch '/candidates/schools/11048/registrations/education',
          params: education_params
      end

      let :education do
        Candidates::Registrations::Education.new
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end

      it "doesn't updated the education in the session" do
        expect(
          registration_session.education.attributes.except('created_at', 'updated_at')
        ).not_to eq education.attributes.except('created_at', 'updated_at')
      end
    end

    context 'valid' do
      before do
        patch '/candidates/schools/11048/registrations/education',
          params: education_params
      end

      let :education do
        FactoryBot.build \
          :education,
          degree_stage: 'Final year',
          degree_stage_explaination: nil
      end

      it 'updates the education in the session' do
        expect(
          registration_session.education.attributes.except('created_at', 'updated_at')
        ).to eq education.attributes.except('created_at', 'updated_at')
      end

      it 'redirects to the application preview page' do
        expect(response).to redirect_to \
          candidates_school_registrations_application_preview_path
      end
    end

    context 'unsetting explanation when changed from other' do
      let :education do
        FactoryBot.build \
          :education,
          degree_stage: 'Other',
          degree_stage_explaination: 'On an important quest'
      end

      before do
        registration_session.save education
      end

      let(:degree_stage) { 'Final year' }
      let(:degree_subject) { 'Art' }
      let(:params) do
        {
          candidates_registrations_education: {
            degree_stage: degree_stage,
            degree_subject: degree_subject
          }
        }
      end

      subject do
        patch '/candidates/schools/11048/registrations/education', params: params
      end

      specify 'should set degree_stage_explaination to nil' do
        expect(registration_session.education.degree_stage_explaination).not_to be_nil
        subject
        expect(registration_session.education.degree_stage_explaination).to be_nil
      end

      specify 'should set the other attributes in the normal fashion' do
        subject
        registration_session.education.tap do |ed|
          expect(ed.degree_stage).to eql(degree_stage)
          expect(ed.degree_subject).to eql(degree_subject)
        end
      end
    end
  end
end
