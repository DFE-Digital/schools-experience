require "rails_helper"

describe NotifyEmail::CandidateBookingFeedbackRequest do
  it_should_behave_like "email template", "189569bd-3115-43e0-8396-be14480a5f2d",
    school_name: "Springfield Elementary",
    candidate_name: "Kearney Zzyzwicz",
    placement_schedule: "2022-03-04 for 3 days",
    feedback_url: "https://example.com/candiates/bookings/abc-123/feedback/new"

  describe ".from_booking" do
    let(:booking) { create(:bookings_booking) }
    let(:candidate) { booking.bookings_placement_request.candidate }

    before do
      candidate.gitis_contact = build(:api_schools_experience_sign_up_with_name)
      candidate.gitis_uuid = candidate.gitis_contact.candidate_id
    end

    subject { described_class.from_booking(booking) }

    context "correctly assigning attributes" do
      it "candidate_name is correctly-assigned" do
        expect(subject.candidate_name).to eql(booking.candidate_name)
      end

      it "school_name is correctly-assigned" do
        expect(subject.school_name).to eql(booking.bookings_school.name)
      end

      it "placement_schedule is correctly-assigned" do
        expect(subject.placement_schedule).to eql(booking.placement_start_date_with_duration)
      end

      it "feedback_url is correctly-assigned" do
        expect(subject.feedback_url).to eql(
          "https://some-host/candidates/bookings/#{booking.token}/feedback/new"
        )
      end
    end
  end
end
