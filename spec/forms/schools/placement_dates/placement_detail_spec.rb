require 'rails_helper'

describe Schools::PlacementDates::PlacementDetail, type: :model do
  context 'validations' do
    context '#start_availability_offset' do
      it do
        expect(subject).to(
          validate_numericality_of(:start_availability_offset)
            .is_greater_than_or_equal_to(1)
            .is_less_than_or_equal_to(180)
        )
      end
      it { expect(subject).to validate_presence_of(:start_availability_offset) }

      it "is greater than #end_availability_offset" do
        subject.end_availability_offset = 1
        is_expected.to allow_value(2).for :start_availability_offset
        is_expected.to_not allow_values(0, 1).for :start_availability_offset
      end
    end

    context '#end_availability_offset' do
      it do
        expect(subject).to(
          validate_numericality_of(:end_availability_offset)
            .is_greater_than_or_equal_to(0)
            .is_less_than_or_equal_to(100)
        )
      end
      it { expect(subject).to validate_presence_of(:end_availability_offset) }
    end

    context '#duration' do
      it do
        expect(subject).to(
          validate_numericality_of(:duration)
            .is_greater_than_or_equal_to(1)
            .is_less_than(100)
        )
      end
      it { expect(subject).to validate_presence_of(:duration) }
    end

    context '#virtual' do
      it { is_expected.to allow_values(true, false).for :virtual }
      it { is_expected.not_to allow_value(nil).for :virtual }
    end

    context '#supports_subjects' do
      context "when placement dates school has primary and secondary phases" do
        include_context 'with phases'

        let(:school) { create(:bookings_school, :primary, :secondary) }
        let(:placement_date) { create :bookings_placement_date, bookings_school: school }

        subject { described_class.new_from_date placement_date }

        it { is_expected.to allow_values(true, false).for :supports_subjects }
        it { is_expected.not_to allow_value(nil).for :supports_subjects }
      end
    end
  end

  context '.new_from_date' do
    subject { described_class.new_from_date placement_date }

    let(:placement_date) { create :bookings_placement_date, published_at: DateTime.now }

    it 'returns a new placement_details with attributes set' do
      expect(placement_date.attributes).to include subject.attributes.except("school_has_primary_and_secondary_phases")
    end
  end

  context '#save' do
    let(:placement_date) { create :bookings_placement_date }
    subject { described_class.new }

    context 'invalid' do
      before { allow(subject).to receive(:valid?).and_return(false) }

      it 'returns false' do
        expect(subject.save(placement_date)).to be false
      end
    end

    context 'valid' do
      let(:placement_date) { create :bookings_placement_date }
      let(:attributes) do
        {
          start_availability_offset: 1,
          end_availability_offset: 1,
          duration: 1,
          virtual: true,
          supports_subjects: true
        }
      end
      let(:placement_date) do
        create :bookings_placement_date,
               start_availability_offset: 100,
               end_availability_offset: 100,
               duration: 100,
               virtual: false,
               supports_subjects: false
      end

      subject { described_class.new(attributes) }

      it 'updates the placement_date subjects to the selected_subjects' do
        expect(placement_date.start_availability_offset).to eq 100
        expect(placement_date.end_availability_offset).to eq 100
        expect(placement_date.duration).to eq 100
        expect(placement_date.virtual).to eq false
        expect(placement_date.supports_subjects).to eq false
      end
    end
  end
end
