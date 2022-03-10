require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementDates::PlacementDetailsController, type: :request do
  include ActiveSupport::Testing::TimeHelpers
  include_context "logged in DfE user"

  let(:school) { Bookings::School.find_by!(urn: urn).tap { |s| create :bookings_profile, school: s } }

  let(:placement_date) { create :bookings_placement_date, bookings_school: school, supports_subjects: false }

  context '#new' do
    before do
      get "/schools/placement_dates/#{placement_date.id}/placement_detail/new"
    end

    it 'assigns the correct placement_date' do
      expect(assigns(:placement_date)).to eq placement_date
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    subject do
      post "/schools/placement_dates/#{placement_date.id}/placement_detail",
           params: params
    end

    context 'invalid' do
      let :params do
        {
          schools_placement_dates_placement_detail: {
            start_availability_offset: nil,
            end_availability_offset: nil,
            duration: nil,
            virtual: nil,
            supports_subjects: nil
          }
        }
      end

      it 're-renders the new template' do
        subject
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :params do
        {
          schools_placement_dates_placement_detail: {
            start_availability_offset: 10,
            end_availability_offset: 5,
            duration: 5,
            virtual: true,
            supports_subjects: supports_subjects
          }
        }
      end

      context "when supports subjects" do
        let(:supports_subjects) { true }

        it 'redirects to the configuration step' do
          subject
          expect(response).to redirect_to new_schools_placement_date_configuration_path placement_date
        end
      end

      context "when does not support subjects" do
        let(:supports_subjects) { false }

        it 'redirects to the publish_dates step' do
          subject
          expect(response).to redirect_to new_schools_placement_date_publish_dates_path(placement_date)
        end
      end

      describe 'setting supports_subjects' do
        context "when supports_subjects hasn't been set" do
          let(:params) do
            {
              schools_placement_dates_placement_detail: {
                start_availability_offset: 10,
                end_availability_offset: 5,
                duration: 5,
                virtual: true
              }
            }
          end

          context "when the school has only primary" do
            before do
              Bookings::School.find_by!(urn: urn).phases << create(:bookings_phase, :primary)
              subject
            end

            it 'sets supports_subjects to false' do
              expect(placement_date.supports_subjects).to be false
            end
          end

          context "when the school has secondary or college" do
            before do
              Bookings::School.find_by!(urn: urn).phases << create(:bookings_phase, :secondary)
              subject
            end

            specify 'supports_subjects should be set to true' do
              expect(placement_date.reload.supports_subjects).to be true
            end
          end
        end
      end
    end
  end
end
