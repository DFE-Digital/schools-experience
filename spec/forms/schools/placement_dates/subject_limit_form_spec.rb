require 'rails_helper'

describe Schools::PlacementDates::SubjectLimitForm, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:placement_date) { create :bookings_placement_date, :per_subject_capped, :unpublished }

  describe 'per_subject_accessor_methods' do
    let(:form) { described_class.new(subject_ids: [1, 2, 3]) }

    describe '#respond_to?' do
      it { expect(form.respond_to?(:max_bookings_count_for_subject_1)).to be true }
      it { expect(form.respond_to?(:max_bookings_count_for_subject_1=)).to be true }
      it { expect(form.respond_to?(:max_bookings_count_for_subject_foo)).to be false }
      it { expect(form.respond_to?(:max_bookings_count_for_subject_foo=)).to be false }
    end

    describe 'read without assigning attribute' do
      context 'for known subject id' do
        subject { form.max_bookings_count_for_subject_1 }
        it { is_expected.to be_nil }
      end

      context 'for unknown subject id' do
        subject { form.max_bookings_count_for_subject_10 }
        it { is_expected.to be_nil }
      end
    end

    describe 'writing attribute' do
      context 'for known subject id' do
        before { form.max_bookings_count_for_subject_1 = '5' }
        it { expect(form).to have_attributes max_bookings_count_for_subject_1: 5 }
      end

      context 'for unknown subject id' do
        before { form.max_bookings_count_for_subject_10 = '5' }
        it { expect(form).to have_attributes max_bookings_count_for_subject_1: nil }
      end
    end
  end

  describe '#validations' do
    subject { described_class.new(subject_ids: [1, 2]) }

    context 'for known virtual attributes' do
      let(:attribute) { :max_bookings_count_for_subject_1 }
      it { is_expected.to allow_value(1).for(attribute) }
      it { is_expected.to allow_value(10).for(attribute) }
      it { is_expected.not_to allow_value(0).for(attribute) }
      it { is_expected.not_to allow_value(0.5).for(attribute) }
      it { is_expected.not_to allow_value(-1).for(attribute) }
      it { is_expected.not_to allow_value(nil).for(attribute) }
      it { is_expected.not_to allow_value('').for(attribute) }
    end

    context 'for unknown virtual attributes' do
      let(:attribute) { :max_bookings_count_for_subject_10 }
      it { is_expected.to allow_value(1).for(attribute) }
      it { is_expected.to allow_value(10).for(attribute) }
      it { is_expected.to allow_value(0).for(attribute) }
      it { is_expected.to allow_value(0.5).for(attribute) }
      it { is_expected.to allow_value(-1).for(attribute) }
      it { is_expected.to allow_value(nil).for(attribute) }
      it { is_expected.to allow_value('').for(attribute) }
    end
  end

  describe '.new_from_date' do
    subject { described_class.new_from_date placement_date }
    let(:pds) { placement_date.placement_date_subjects[0] }

    it "will retrieve subject_ids from placement_date" do
      is_expected.to have_attributes \
        subject_ids: placement_date.subject_ids
    end

    it "will retrieve counts from placement_date" do
      is_expected.to have_attributes \
        :"max_bookings_count_for_subject_#{pds.bookings_subject_id}" =>
          pds.max_bookings_count
    end
  end

  describe '#save' do
    let(:pds) { placement_date.placement_date_subjects[0] }
    let(:subject_id) { pds.bookings_subject_id }

    let(:attrname) { :"max_bookings_count_for_subject_#{subject_id}" }

    subject { described_class.new(subject_ids: placement_date.subject_ids) }

    context 'when invalid form' do
      before { subject.send :"#{attrname}=", 0 }
      it { expect(subject.save(placement_date)).to be false }
    end

    context 'when valid form' do
      before { subject.send :"#{attrname}=", 5 }

      context 'when valid placement_date' do
        let!(:result) { subject.save placement_date }

        it { expect(result).to be true }

        it('will update date subjects') do
          expect(pds.reload).to have_attributes \
            bookings_subject_id: subject_id,
            max_bookings_count: 5
        end

        it('will publish the placement date') do
          expect(placement_date.reload).to be_published
        end
      end

      context 'when invalid placement_date' do
        before { allow(placement_date).to receive(:valid?).and_return(false) }

        it "will raise an error and not save" do
          expect { subject.save(placement_date) }.to raise_exception \
            ActiveRecord::RecordInvalid

          expect(pds.reload).not_to \
            have_attributes max_bookings_count: 5

          expect(placement_date.reload).not_to be_published
        end
      end
    end
  end
end
