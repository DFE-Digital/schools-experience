require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::ArchivedPlacementRequestsController, type: :request do
  include_context "logged in DfE user"

  let(:school) { Bookings::School.find_by! urn: urn }
  let!(:profile) { create :bookings_profile, school: school }

  before do
    school.subjects << create_list(:bookings_subject, 1)
  end

  describe '#index' do
    subject { response }

    it { is_expected.to have_http_status :success }
    it { is_expected.to render_template 'index' }

    before do
      get schools_archived_placement_requests_path
    end

    context 'when flex dates' do
      before { create :placement_request, created_at: 3.months.ago, school: school }

      it 'displays only placement requests that expired longer than a month ago' do
        expect(assigns(:placement_requests).count).to eq(1)
      end

      context 'with long expired and processed requests' do
        it 'does not displays them' do
          create :placement_request, :cancelled_by_school, created_at: 3.months.ago, school: school

          expect(assigns(:placement_requests).count).to eq(1)
        end
      end

      context 'with processed requests' do
        it 'does not displays them' do
          create :placement_request, :cancelled_by_school, school: school

          expect(assigns(:placement_requests).count).to eq(1)
        end
      end

      context 'with unprocessed requests' do
        it 'does not displays them' do
          create :placement_request, school: school

          expect(assigns(:placement_requests).count).to eq(1)
        end
      end

      context 'with recently expired requests' do
        it 'does not displays them' do
          create :placement_request, created_at: 3.days.ago, school: school

          expect(assigns(:placement_requests).count).to eq(1)
        end
      end
    end

    context 'when fixed dates' do
      before do
        school.update(availability_preference_fixed: true)
        create :placement_request, :with_a_fixed_date_in_the_past, school: school
      end

      it 'displays only placement requests that expired longer than a month ago' do
        expect(assigns(:placement_requests).count).to eq(1)
      end

      context 'with long expired and processed requests' do
        it 'does not displays them' do
          create :placement_request, :with_a_fixed_date_in_the_past, :cancelled_by_school, school: school

          expect(assigns(:placement_requests).count).to eq(1)
        end
      end

      context 'with processed requests' do
        it 'does not displays them' do
          create :placement_request, :with_a_fixed_date, :cancelled_by_school, school: school

          expect(assigns(:placement_requests).count).to eq(1)
        end
      end

      context 'with unprocessed requests' do
        it 'does not displays them' do
          create :placement_request, :with_a_fixed_date, school: school

          expect(assigns(:placement_requests).count).to eq(1)
        end
      end

      context 'with recently expired requests' do
        it 'does not displays them' do
          create :placement_request, :with_a_fixed_date_in_the_recent_past, school: school

          expect(assigns(:placement_requests).count).to eq(1)
        end
      end
    end
  end
end
