require 'rails_helper'

describe Schools::AttendanceRecords, type: :model do
  describe "#records" do
    let(:booking) { create :bookings_booking, :accepted, :attended }
    let(:school_urns) { [booking.bookings_school.urn] }
    let(:candidate_id) { booking.bookings_placement_request.candidate_id }
    subject { records.records }

    context 'with matching urn' do
      context 'but different candidate' do
        let(:records) { described_class.new 10000000, school_urns }
        it { is_expected.not_to include booking }
      end

      context 'with matching candidate' do
        let(:records) { described_class.new candidate_id, school_urns }

        context 'and attended' do
          it { is_expected.to include booking }
        end

        context 'and did not attend' do
          let(:booking) { create :bookings_booking, :accepted, :unattended }
          it { is_expected.to include booking }
        end

        context 'and no attendance info' do
          let(:booking) { create :bookings_booking, :accepted }
          it { is_expected.not_to include booking }
        end
      end
    end

    context 'for URN not in list' do
      let(:records) { described_class.new candidate_id, [999999999, 999999990] }
      it { is_expected.not_to include booking }
    end
  end

  describe 'counts' do
    let(:candidate) { create(:candidate) }
    let(:school) { create(:bookings_school) }
    let(:second_school) { create(:bookings_school) }

    let!(:attended) do
      create :bookings_booking, :accepted, :attended,
        bookings_school: school,
        bookings_placement_request:
          create(:bookings_placement_request, school: school, candidate: candidate)
    end

    let!(:did_not_attend) do
      create :bookings_booking, :accepted, :unattended,
        bookings_school: school,
        bookings_placement_request:
          create(:bookings_placement_request, school: school, candidate: candidate)
    end

    let!(:another_school) do
      create :bookings_booking, :accepted, :attended,
        bookings_school: second_school,
        bookings_placement_request:
          create(:bookings_placement_request,
            school: second_school,
            candidate: candidate)
    end

    let!(:another_candidate) do
      create :bookings_booking, :accepted, :attended,
        bookings_school: school,
        bookings_placement_request:
          create(:bookings_placement_request, school: school)
    end

    let(:urns) { [school.urn] }
    let(:records) { described_class.new candidate.id, urns }

    describe '#attended_count' do
      subject { records.attended_count }
      it { is_expected.to eq 1 }

      context 'for both schools' do
        let(:urns) { [school.urn, second_school.urn] }
        it { is_expected.to eq 2 }
      end
    end

    describe '#did_not_attend_count' do
      subject { records.did_not_attend_count }
      it { is_expected.to eq 1 }
    end
  end
end
