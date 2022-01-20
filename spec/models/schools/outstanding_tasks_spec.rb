require "rails_helper"

describe Schools::OutstandingTasks do
  let(:school) { create :bookings_school, :with_subjects }
  let(:other_school) { create :bookings_school, :with_subjects }

  describe "#summarize" do
    let(:summary) { described_class.new([school.urn, other_school.urn]).summarize }

    context "requests_requiring_attention" do
      subject { compact_summary(:requests_requiring_attention) }

      it { is_expected.to eq({ school.urn => 0, other_school.urn => 0 }) }

      context "when there are requests requiring attention" do
        before do
          create(:placement_request, school: school)
        end

        it { is_expected.to eq({ school.urn => 1, other_school.urn => 0 }) }

        context "when there are also requests not requiring attention" do
          before do
            create(:placement_request, :booked, school: school)
            create(:placement_request, :cancelled, school: school)
          end

          it { is_expected.to eq({ school.urn => 1, other_school.urn => 0 }) }
        end

        context "when there are also other school requests requiring attention" do
          before { create(:placement_request, school: other_school) }

          it { is_expected.to eq({ school.urn => 1, other_school.urn => 1 }) }
        end
      end
    end

    context "unviewed_withdrawn_requests" do
      subject { compact_summary(:unviewed_withdrawn_requests) }

      it { is_expected.to eq({ school.urn => 0, other_school.urn => 0 }) }

      context "when there are unviewed, withdrawn placement requests" do
        before { create(:placement_request, :cancelled, school: school) }

        it { is_expected.to eq({ school.urn => 1, other_school.urn => 0 }) }

        context "when there are also viewed, withdrawn placement requests" do
          before do
            create(:placement_request, :cancelled, school: school).tap do |pr|
              pr.candidate_cancellation.viewed!
            end
          end

          it { is_expected.to eq({ school.urn => 1, other_school.urn => 0 }) }
        end

        context "when there are also other schools with unviewed, withdrawn placement requests" do
          before { create(:placement_request, :cancelled, school: other_school) }

          it { is_expected.to eq({ school.urn => 1, other_school.urn => 1 }) }
        end
      end
    end

    context "upcoming_bookings" do
      subject { compact_summary(:upcoming_bookings) }

      it { is_expected.to eq({ school.urn => 0, other_school.urn => 0 }) }

      context "when there are bookings requiring attention" do
        before { create(:bookings_booking, :cancelled_by_candidate, bookings_school: school) }

        it { is_expected.to eq({ school.urn => 1, other_school.urn => 0 }) }

        context "when there are also bookings not requiring attention" do
          before do
            create(:placement_request, :booked, school: school)
            create(:bookings_booking, :with_viewed_candidate_cancellation, bookings_school: school)
            create(:bookings_booking, :cancelled_by_school, bookings_school: school)
          end

          it { is_expected.to eq({ school.urn => 1, other_school.urn => 0 }) }
        end

        context "when there are also other schools with bookings requiring attention" do
          before { create(:bookings_booking, :cancelled_by_candidate, bookings_school: other_school) }

          it { is_expected.to eq({ school.urn => 1, other_school.urn => 1 }) }
        end
      end
    end

    context "bookings_pending_attendance_confirmation" do
      subject { compact_summary(:bookings_pending_attendance_confirmation) }

      it { is_expected.to eq({ school.urn => 0, other_school.urn => 0 }) }

      context "when there are bookings pending attendance confirmation" do
        before do
          create(:placement_request, :booked, school: school) do |pr|
            pr.booking.update_columns date: Date.yesterday
          end
        end

        it { is_expected.to eq({ school.urn => 1, other_school.urn => 0 }) }

        context "when there are also bookings not pending attendance confirmation" do
          before do
            create(:placement_request, :booked, school: school) do |pr|
              pr.booking.update_columns date: Date.yesterday, attended: false
            end
          end

          it { is_expected.to eq({ school.urn => 1, other_school.urn => 0 }) }
        end

        context "when there are also other schools with bookings pending attendance confirmation" do
          before do
            create(:placement_request, :booked, school: other_school) do |pr|
              pr.booking.update_columns date: Date.yesterday
            end
          end

          it { is_expected.to eq({ school.urn => 1, other_school.urn => 1 }) }
        end
      end
    end
  end

  def compact_summary(key)
    summary.transform_values { |v| v[key] }
  end
end
