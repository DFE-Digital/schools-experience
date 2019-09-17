require 'rails_helper'

describe NotifyEmail::CandidateRequestConfirmationNoPii do
  it_should_behave_like "email template", "8ee470a1-0b94-48ee-9fe7-98b7beb8921c",
    school_name: "Springfield Elementary School",
    candidate_dbs_check_document: "Yes",
    candidate_degree_stage: "Postgraduate",
    candidate_degree_subject: "Sociology",
    candidate_teaching_stage: "I want to become a teacher",
    candidate_teaching_subject_first_choice: "Sociology",
    candidate_teaching_subject_second_choice: "Philosophy",
    placement_availability: "Mid lent",
    placement_outcome: "I enjoy teaching",
    cancellation_url: 'https://example.com/'

  describe ".from_application_preview" do
    before do
      stub_const(
        'Notify::API_KEY',
        ["somekey", SecureRandom.uuid, SecureRandom.uuid].join("-")
      )
    end

    specify { expect(described_class).to respond_to(:from_application_preview) }

    let!(:school) { create(:bookings_school, urn: 11048) }
    let(:rs) { build(:registration_session) }
    let(:to) { "morris.szyslak@moes.net" }
    let(:cancellation_url) { 'https://example.com/placement_request/cancellations' }
    let(:ap) { Candidates::Registrations::ApplicationPreview.new(rs) }

    subject { described_class.from_application_preview(to, ap, cancellation_url) }

    it { is_expected.to be_a(described_class) }

    context 'correctly assigning attributes' do
      specify 'cancellation_url is correctly-assigned' do
        expect(subject.cancellation_url).to eql(cancellation_url)
      end

      specify 'candidate_dbs_check_document is correctly-assigned' do
        expect(subject.candidate_dbs_check_document).to eql(ap.dbs_check_document)
      end

      specify 'candidate_degree_stage is correctly-assigned' do
        expect(subject.candidate_degree_stage).to eql(ap.degree_stage)
      end

      specify 'candidate_teaching_stage is correctly-assigned' do
        expect(subject.candidate_teaching_stage).to eql(ap.teaching_stage)
      end

      specify 'candidate_teaching_subject_first_choice is correctly-assigned' do
        expect(subject.candidate_teaching_subject_first_choice).to eql(ap.teaching_subject_first_choice)
      end

      specify 'candidate_teaching_subject_second_choice is correctly-assigned' do
        expect(subject.candidate_teaching_subject_second_choice).to eql(ap.teaching_subject_second_choice)
      end

      specify 'placement_outcome is correctly-assigned' do
        expect(subject.placement_outcome).to eql(ap.placement_outcome)
      end

      specify 'school_name is correctly-assigned' do
        expect(subject.school_name).to eql(ap.school.name)
      end

      context 'placement availability/dates' do
        context 'when school availability is flexible' do
          specify 'placement_availability is correctly-assigned' do
            expect(subject.placement_availability).to eql(ap.placement_availability)
          end
        end

        context 'when the school has set dates' do
          let(:rs) { build(:registration_session, :with_placement_date) }
          specify 'bookings_placement_date_id is correctly-assigned' do
            expect(subject.placement_availability).to eql(Bookings::PlacementDate.last.to_s)
          end
        end
      end
    end
  end
end
