require 'rails_helper'

describe Bookings::Gitis::SchoolExperience, type: :model do
  describe "validations" do
    let(:model) { create(:placement_request, :booked) }
    let(:status) { :requested }
    subject { described_class.from_placement_request(model, status) }

    before { allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to receive(:add_school_experience) }

    context "with valid arguments" do
      it "does not throw error" do
        expect { subject }.to_not raise_error
      end
    end

    describe "#urn" do
      it "is invalid when too long" do
        model.school.urn = 123_456_789
        expect { subject }.to raise_exception ActiveModel::ValidationError, "Validation failed: Urn is too long (maximum is 8 characters)"
      end
    end

    describe "#duration" do
      let(:placement_date) { create(:bookings_placement_date) }

      before do
        placement_date.duration = 101
        model.placement_date = placement_date
      end

      it "is invalid when too long" do
        expect { subject }.to raise_exception ActiveModel::ValidationError, "Validation failed: Duration must be less than or equal to 100"
      end
    end

    describe "#school_name" do
      it "is invalid when too long" do
        model.school.name = "*" * 101
        expect { subject }.to raise_exception ActiveModel::ValidationError, "Validation failed: School name is too long (maximum is 100 characters)"
      end
    end

    describe "#status" do
      let(:status) { :invalid }

      it "is invalid when not included in the list of statuses" do
        expect { subject }.to raise_exception ActiveModel::ValidationError, "Validation failed: Status is not included in the list"
      end
    end
  end

  it 'cannot be directly instantiated' do
    expect { described_class.new(any_args) }.to raise_exception NoMethodError
  end

  let(:gitis_id) { SecureRandom.uuid }
  let(:subject_id) { 275_000_001 }
  let(:subject_name) { "Maths" }

  shared_examples "a successful API post" do
    before do
      expect_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi)
        .to receive(:add_school_experience).with(gitis_id, expected_school_experience)

      allow_any_instance_of(GetIntoTeachingApiClient::LookupItemsApi)
        .to receive(:get_teaching_subjects).and_return([build(:api_lookup_item, id: subject_id, value: subject_name)])
    end

    describe "#write_to_gitis_contact" do
      it "posts to gitis" do
        subject.write_to_gitis_contact(gitis_id)
      end
    end
  end

  context 'with a Bookings::PlacementRequest' do
    let(:status) { :requested }
    let(:placement_request) { create(:placement_request, :with_incomplete_booking) }

    let(:expected_school_experience) do
      GetIntoTeachingApiClient::CandidateSchoolExperience.new(
        school_urn: placement_request.school.urn.to_s,
        status: 1,
        school_name: placement_request.school.name
      )
    end

    subject { described_class.from_placement_request(placement_request, status) }

    context "with flexible dates" do
      it_behaves_like "a successful API post"
    end

    context "with fixed dates" do
      let(:placement_date) { create(:bookings_placement_date, bookings_school: placement_request.school) }
      let(:date) { placement_date.date }
      before do
        expected_school_experience.date_of_school_experience = date
        expected_school_experience.duration_of_placement_in_days = 1
        placement_request.update!(placement_date: placement_date)
      end

      it_behaves_like "a successful API post"
    end
  end

  context "with a Bookings::Booking" do
    let(:status) { :confirmed }
    let(:booking) { create(:bookings_booking, :accepted) }

    let(:expected_school_experience) do
      GetIntoTeachingApiClient::CandidateSchoolExperience.new(
        school_urn: booking.bookings_school.urn.to_s,
        status: 222_750_000,
        school_name: booking.bookings_school.name,
        duration_of_placement_in_days: 1,
        date_of_school_experience: booking.date
      )
    end

    subject { described_class.from_booking(booking, status) }

    context "without existing subject" do
      it_behaves_like "a successful API post"
    end

    context "with existing subject" do
      let(:booking) { create(:bookings_booking, :with_existing_subject, :accepted) }
      let(:subject_name) { booking.bookings_subject.name }
      before do
        expected_school_experience.teaching_subject_id = subject_id
      end

      it_behaves_like "a successful API post"
    end

    context "when attended" do
      let(:status) { :completed }
      before do
        booking.update!(attended: true)
        expected_school_experience.status = 222_750_005
      end

      it_behaves_like "a successful API post"
    end
  end

  context "with a Bookings::Cancellation" do
    subject { described_class.from_cancellation(cancellation, status) }

    context "cancelled by candidate" do
      let(:status) { :cancelled_by_candidate }

      context "when cancelled after being accepted" do
        let(:expected_school_experience) do
          GetIntoTeachingApiClient::CandidateSchoolExperience.new(
            school_urn: cancellation.school_urn.to_s,
            status: 222_750_004,
            school_name: cancellation.school_name,
            duration_of_placement_in_days: 1,
            date_of_school_experience: cancellation.booking.date
          )
        end
        let(:cancellation) { create(:bookings_booking, :cancelled_by_candidate).candidate_cancellation }

        it_behaves_like "a successful API post"
      end

      context "when cancelled before accepted" do
        let(:expected_school_experience) do
          GetIntoTeachingApiClient::CandidateSchoolExperience.new(
            school_urn: cancellation.school_urn.to_s,
            status: 222_750_004,
            school_name: cancellation.school_name,
            duration_of_placement_in_days: cancellation.placement_request.placement_date&.duration,
            date_of_school_experience: cancellation.placement_request.placement_date&.date,
          )
        end
        let(:cancellation) { create(:placement_request, :cancelled).candidate_cancellation }

        it_behaves_like "a successful API post"
      end
    end

    context "cancelled by school" do
      let(:status) { :cancelled_by_school }
      let(:cancellation) { create(:bookings_booking, :cancelled_by_school).school_cancellation }
      let(:expected_school_experience) do
        GetIntoTeachingApiClient::CandidateSchoolExperience.new(
          school_urn: cancellation.school_urn.to_s,
          status: 222_750_003,
          school_name: cancellation.school_name,
          duration_of_placement_in_days: 1,
          date_of_school_experience: cancellation.booking.date
        )
      end

      it_behaves_like "a successful API post"
    end
  end
end
