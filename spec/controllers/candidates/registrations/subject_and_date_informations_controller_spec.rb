require 'rails_helper'

describe Candidates::Registrations::SubjectAndDateInformationsController, type: :request do
  let :registration_session do
    FactoryBot.build :registration_session, with: %i()
  end

  describe '#get' do
    let :subject_and_date_info_path do
      '/candidates/schools/11048/registrations/subject_and_date_information/new'
    end

    context 'when the school has flexible dates' do
      include_context 'Stubbed candidates school'

      context 'without existing subject and date in session' do
        before do
          get '/candidates/schools/11048/registrations/subject_and_date_information/new'
        end

        it('responds with 302') { expect(response.status).to eq 302 }

        it 'should redirect to the personal information page' do
          expect(response.header.dig("Location")).to end_with('schools/11048/registrations/personal_information/new')
        end
      end
    end

    context 'when the school has fixed dates' do
      include_context 'Stubbed candidates school', true

      context 'without existing subject and date in session' do
        before do
          get '/candidates/schools/11048/registrations/subject_and_date_information/new'
        end

        it('responds with 302') { expect(response.status).to eq 200 }
      end

      context 'with existing subject and date in session' do
        let :registration_session do
          FactoryBot.build :registration_session, with: %i(subject_and_date_information)
        end

        before { get subject_and_date_info_path }

        # allowing for registrants to click 'back'
        it('responds with 200') do
          expect(response.status).to eq 200
        end
      end
    end
  end

  describe '#post' do
    include_context 'Stubbed candidates school', true
    let :subject_and_date_info_path do
      '/candidates/schools/11048/registrations/subject_and_date_information'
    end

    context 'when the school has primary dates' do
      let(:primary_placement_date) { create(:bookings_placement_date, bookings_school: school, supports_subjects: false) }
      let(:params) do
        {
          candidates_registrations_subject_and_date_information: {
            subject_and_date_ids: primary_placement_date.id
          }
        }
      end

      subject! { post subject_and_date_info_path, params: params }

      specify 'correctly stores the primary placement date in the registration session' do
        expect(
          session.to_h.dig('schools/11048/registrations', 'candidates_registrations_subject_and_date_information', 'bookings_placement_date_id')
        ).to eql(primary_placement_date.id)
      end
    end

    context 'when no parameters are supplied' do
      let(:params) do
        {}
      end

      subject { post subject_and_date_info_path, params: params }

      specify { expect { subject }.to raise_error(ActionController::ParameterMissing, /candidates_registrations_subject_and_date_information/) }
    end

    context 'when the school has secondary non-subject-specific dates' do
      let(:secondary_placement_date) { create(:bookings_placement_date, bookings_school: school, supports_subjects: true) }
      let(:params) do
        {
          candidates_registrations_subject_and_date_information: {
            subject_and_date_ids: secondary_placement_date.id
          }
        }
      end

      subject! { post subject_and_date_info_path, params: params }

      specify 'correctly stores the secondary placement date in the registration session' do
        expect(
          session.to_h.dig('schools/11048/registrations', 'candidates_registrations_subject_and_date_information', 'bookings_placement_date_id')
        ).to eql(secondary_placement_date.id)
      end

      specify 'stores no subject information' do
        expect(
          session.to_h.dig('schools/11048/registrations', 'candidates_registrations_subject_and_date_information', 'bookings_placement_dates_subject_id')
        ).to be_nil
      end
    end

    context 'when the school has secondary subject-specific dates' do
      let(:bookings_subject) { create(:bookings_subject) }

      before { school.subjects << bookings_subject }

      let(:secondary_placement_date) do
        build(:bookings_placement_date, bookings_school: school, subject_specific: true, supports_subjects: true).tap do |pd|
          pd.subjects << bookings_subject
          pd.save
        end
      end

      let(:placement_date_subject) { secondary_placement_date.placement_date_subjects.first }

      let(:params) do
        {
          candidates_registrations_subject_and_date_information: {
            subject_and_date_ids: [secondary_placement_date.id, placement_date_subject.id].join('_')
          }
        }
      end

      subject! { post subject_and_date_info_path, params: params }

      specify 'correctly stores the secondary placement date in the registration session' do
        expect(
          session.to_h.dig('schools/11048/registrations', 'candidates_registrations_subject_and_date_information', 'bookings_placement_date_id')
        ).to eql(secondary_placement_date.id)
      end

      specify 'correctly stores the secondary subject in the registration session' do
        expect(
          session.to_h.dig('schools/11048/registrations', 'candidates_registrations_subject_and_date_information', 'bookings_subject_id')
        ).to be(bookings_subject.id)
      end
    end
  end
end
