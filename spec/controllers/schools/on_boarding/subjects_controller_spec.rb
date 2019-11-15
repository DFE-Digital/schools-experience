require 'rails_helper'

require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::OnBoarding::SubjectsController, type: :request do
  include_context "logged in DfE user"

  let! :bookings_subject do
    FactoryBot.create :bookings_subject
  end

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
      :with_phases,
      :with_key_stage_list
  end

  context '#new' do
    before do
      get '/schools/on_boarding/subjects/new'
    end

    it 'assigns the model' do
      expect(assigns(:subject_list)).to eq Schools::OnBoarding::SubjectList.new
    end

    it 'renders the new template' do
      expect(response.body).to render_template :new
    end
  end

  context '#create' do
    before do
      post '/schools/on_boarding/subjects', params: params
    end

    context 'invalid' do
      let :params do
        {
          schools_on_boarding_subject_list: { subject_ids: [] }
        }
      end

      it "doesn't update the school profile" do
        expect(school_profile.reload.subjects).to be_empty
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :params do
        {
          schools_on_boarding_subject_list: {
            subject_ids: [bookings_subject.id]
          }
        }
      end

      it 'updates the school profile with the subjects' do
        expect(school_profile.reload.subjects).to \
          eq [bookings_subject]
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to new_schools_on_boarding_description_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/subjects/edit'
    end

    it 'assigns the model' do
      expect(assigns(:subject_list).subject_ids).to \
        eq school_profile.subject_ids
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
        schools_on_boarding_subject_list: { subject_ids: subject_list }
      }
    end

    before do
      patch '/schools/on_boarding/subjects', params: params
    end

    context 'invalid' do
      let :subject_list do
        []
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.subject_ids).not_to \
          eq subject_list
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :subject_list do
        [FactoryBot.create(:bookings_subject).id]
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.subject_ids).to eq subject_list
      end

      it 'redirects to the school_profile' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
