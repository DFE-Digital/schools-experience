require 'rails_helper'

describe Schools::AttendanceRecords, type: :model do
  describe "#records" do
    subject { records.records }

    let(:booking) { create :bookings_booking, :accepted, :attended }
    let(:school_urns) { [booking.bookings_school.urn] }
    let(:candidate_id) { booking.bookings_placement_request.candidate_id }


    context 'with matching urn' do
      context 'when but different candidate' do
        let(:records) { described_class.new 10_000_000, school_urns }

        it { is_expected.not_to include booking }
      end

      context 'with matching candidate' do
        let(:records) { described_class.new candidate_id, school_urns }

        context 'when the candidate attended' do
          it { is_expected.to include booking }
        end

        context 'when the candidate did not attend' do
          let(:booking) { create :bookings_booking, :accepted, :unattended }

          it { is_expected.to include booking }
        end

        context 'without attendance info' do
          let(:booking) { create :bookings_booking, :accepted }

          it { is_expected.not_to include booking }
        end
      end
    end

    context 'with URN not in list' do
      let(:records) { described_class.new candidate_id, [999_999_999, 999_999_990] }

      it { is_expected.not_to include booking }
    end
  end

  describe 'counts' do
    let(:candidate) { create(:candidate) }
    let(:urns) { [school.urn] }
    let(:records) { described_class.new candidate.id, urns }
    let(:school) { create(:bookings_school) }
    let(:second_school) { create(:bookings_school) }

    before do
      create :bookings_booking, :accepted, :attended,
        bookings_school: school,
        bookings_placement_request:
          create(:bookings_placement_request, school: school, candidate: candidate)
create :bookings_booking, :accepted, :unattended,
        bookings_school: school,
        bookings_placement_request:
          create(:bookings_placement_request, school: school, candidate: candidate)

create :bookings_booking, :accepted, :attended,
        bookings_school: second_school,
        bookings_placement_request:
          create(:bookings_placement_request,
            school: second_school,
            candidate: candidate)

create :bookings_booking, :accepted, :attended,
        bookings_school: school,
        bookings_placement_request:
          create(:bookings_placement_request, school: school)

    end





    describe '#attended_count' do
      subject { records.attended_count }

      it { is_expected.to eq 1 }

      context 'when applied to both schools' do
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
