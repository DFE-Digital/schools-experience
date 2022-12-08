require "rails_helper"
require "placement_request_transfer"

RSpec.describe PlacementRequestTransfer do
  let(:placement_request) { create(:placement_request) }
  let(:school) { create(:bookings_school) }
  let(:placement_request_id) { placement_request.id }
  let(:school_id) { school.id }

  describe "#transfer!" do
    let(:instance) { described_class.new(placement_request_id, school_id) }

    subject(:transfer) { instance.transfer! }

    it { expect { transfer }.to change { placement_request.reload.school }.to(school) }

    context "when the placement request has been viewed" do
      before { placement_request.viewed! }

      it { expect { transfer }.to change { placement_request.reload.school }.to(school) }
    end

    context "when the placement request is subject specific" do
      let(:placement_request) { create(:placement_request, :subject_specific) }

      context "when a matching subject is found in the school" do
        before do
          school.subjects = placement_request.school.subjects
          school.save!
        end

        it "transfers the placement request and retains the subject" do
          transfer
          placement_request.reload

          expect(placement_request.school).to eq(school)
          expect(placement_request.subject).to be_present
        end
      end

      context "when a matching subject is not found in the school" do
        let(:message) { "could not match subject '#{placement_request.subject.name}' in school" }

        it { expect { transfer }.to raise_error(described_class::TransferError).with_message(message) }
      end
    end

    context "when the subject_first_choice is not available in the school" do
      let(:message) { "school does not support subject '#{placement_request.subject_first_choice}'" }

      before { school.update(subjects: [create(:bookings_subject, name: "Test")]) }

      it { expect { transfer }.to raise_error(described_class::TransferError).with_message(message) }
    end

    context "when the placement request has a fixed placement date" do
      let(:placement_request) { create(:placement_request, :with_a_fixed_date) }

      context "when the school supports fixed availability dates" do
        before { school.update(availability_preference_fixed: true) }

        it "transfers the placement request and links to a matching date in the school" do
          placement_date = create(:bookings_placement_date,
            :active,
            date: placement_request.placement_date.date,
            bookings_school: school)

          transfer
          placement_request.reload

          expect(placement_request.school).to eq(school)
          expect(placement_request.placement_date).to eq(placement_date)
        end

        context "when a matching placement date is not found in the school" do
          let(:message) { "could not match fixed placement date '#{placement_request.placement_date.date}' in school" }

          before do
            school.update(availability_preference_fixed: true)
            create(:bookings_placement_date,
              :active,
              date: placement_request.placement_date.date + 1.week,
              bookings_school: school)
          end

          it { expect { transfer }.to raise_error(described_class::TransferError).with_message(message) }
        end
      end

      context "when the school does not support fixed placement dates" do
        let(:message) { "school does not support fixed placement dates" }

        it { expect { transfer }.to raise_error(described_class::TransferError).with_message(message) }
      end
    end

    context "when the placement is flexible but the school supports fixed dates" do
      let(:message) { "school does not support flexible placement dates" }

      before { school.update(availability_preference_fixed: true) }

      it { expect { transfer }.to raise_error(described_class::TransferError).with_message(message) }
    end

    context "when the school experience types are incompatible" do
      let(:message) { "school does not support #{placement_request.experience_type} experience type" }

      before { school.update(experience_type: "virtual") }

      it { expect { transfer }.to raise_error(described_class::TransferError).with_message(message) }
    end

    context "when the placement request does not exist" do
      let(:placement_request_id) { -1 }

      it { expect { transfer }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context "when the school does not exist" do
      let(:school_id) { -1 }

      it { expect { transfer }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context "when the placement request has a booking" do
      let(:message) { "you cannot transfer a booked placement request" }
      let(:placement_request) { create(:placement_request, :booked) }

      it { expect { transfer }.to raise_error(described_class::TransferError).with_message(message) }
    end

    context "when the placement request has expired" do
      let(:message) { "you cannot transfer a placement request with a 'Expired' status" }
      let(:placement_request) { create(:placement_request, :with_a_fixed_date_in_the_past) }

      it { expect { transfer }.to raise_error(described_class::TransferError).with_message(message) }
    end

    context "when the placement request is under consideration" do
      let(:message) { "you cannot transfer a placement request with a 'Under consideration' status" }

      before { placement_request.update(under_consideration_at: Date.today) }

      it { expect { transfer }.to raise_error(described_class::TransferError).with_message(message) }
    end

    context "when the placement request is flagged" do
      let(:message) { "you cannot transfer a placement request with a 'Flagged' status" }
      let(:candidate) { create(:recurring_candidate, school: placement_request.school) }

      before { placement_request.update(candidate: candidate) }

      it { expect { transfer }.to raise_error(described_class::TransferError).with_message(message) }
    end

    context "when the placement request has been cancelled by the school" do
      let(:message) { "you cannot transfer a placement request with a 'Rejected' status" }
      let(:placement_request) { create(:placement_request, :cancelled_by_school) }

      it { expect { transfer }.to raise_error(described_class::TransferError).with_message(message) }
    end

    context "when the placement request has been withdrawn by the candidate" do
      let(:message) { "you cannot transfer a placement request with a 'Withdrawn' status" }
      let(:placement_request) { create(:placement_request, :cancelled) }

      it { expect { transfer }.to raise_error(described_class::TransferError).with_message(message) }
    end
  end
end
