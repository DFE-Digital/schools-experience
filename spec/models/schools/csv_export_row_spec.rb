require "rails_helper"

RSpec.describe Schools::CsvExportRow do
  describe "#row" do
    subject { Hash[Schools::CsvExport::HEADER.zip(row)] }

    let(:contact) { build :api_schools_experience_sign_up }

    let(:row) do
      pr.gitis_contact = contact
      described_class.new(pr).row
    end

    context "a placement request without a booking" do
      context "for a fixed date school" do
        let(:pr) { create :placement_request, :with_a_fixed_date }

        it { is_expected.to include "Id" => pr.id }
        it { is_expected.to include "Name" => contact.full_name }
        it { is_expected.to include "Email" => contact.email }
        it { is_expected.to include "Date" => pr.placement_date.date.to_formatted_s(:govuk) }
        it { is_expected.to include "Duration" => pr.placement_date.duration }
        it { is_expected.to include "Subject" => pr.subject_first_choice }
        it { is_expected.to include "Status" => "New" }
        it { is_expected.to include "Attendance" => nil }

        context "which has been cancelled by the school" do
          let(:pr) { create :placement_request, :cancelled_by_school, :with_a_fixed_date }

          it { is_expected.to include "Status" => "Rejected" }
        end

        context "which has been cancelled by the candidate" do
          let(:pr) { create :placement_request, :cancelled, :with_a_fixed_date }

          it { is_expected.to include "Status" => "Withdrawn" }
        end
      end

      context "for a flexible date school" do
        let(:pr) { create :placement_request }

        it { is_expected.to include "Id" => pr.id }
        it { is_expected.to include "Name" => contact.full_name }
        it { is_expected.to include "Email" => contact.email }
        it { is_expected.to include "Date" => nil }
        it { is_expected.to include "Duration" => nil }
        it { is_expected.to include "Subject" => pr.subject_first_choice }
        it { is_expected.to include "Status" => "New" }
        it { is_expected.to include "Attendance" => nil }
      end
    end

    context "with a placement request with future a booking" do
      let(:pr) { create(:bookings_booking, :accepted).bookings_placement_request }

      it { is_expected.to include "Id" => pr.id }
      it { is_expected.to include "Name" => contact.full_name }
      it { is_expected.to include "Email" => contact.email }
      it { is_expected.to include "Date" => pr.booking.date.to_formatted_s(:govuk) }
      it { is_expected.to include "Duration" => pr.booking.duration }
      it { is_expected.to include "Subject" => pr.booking.bookings_subject.name }
      it { is_expected.to include "Status" => "Booked" }
      it { is_expected.to include "Attendance" => nil }

      context "which has been cancelled by the school" do
        let(:pr) do
          create(:bookings_booking, :accepted, :cancelled_by_school)
            .bookings_placement_request
        end

        it { is_expected.to include "Status" => "School cancellation" }
      end

      context "which has been cancelled by the candidate" do
        let(:pr) do
          create(:bookings_booking, :accepted, :cancelled_by_candidate)
            .bookings_placement_request
        end

        it { is_expected.to include "Status" => "Candidate cancellation" }
      end
    end

    context "with a placement request with a booking which has passed" do
      subject { row[Schools::CsvExport.column("Attendance")] }

      let(:pr) do
        create(:bookings_booking, :accepted, attended: attended)
          .bookings_placement_request
      end

      context "with no attendance information" do
        let(:attended) { nil }

        it { is_expected.to be_nil }
      end

      context "with an attendance" do
        let(:attended) { true }

        it { is_expected.to eql "Attended" }
      end

      context "with a did not attend" do
        let(:attended) { false }

        it { is_expected.to eql "Did not attend" }
      end
    end
  end
end
