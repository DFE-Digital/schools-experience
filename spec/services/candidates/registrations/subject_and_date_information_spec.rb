require 'rails_helper'

describe Candidates::Registrations::SubjectAndDateInformation, type: :model do
  include_context 'Stubbed candidates school', fixed: true
  it_behaves_like 'a registration step'

  describe 'attributes' do
    it { is_expected.to respond_to :availability }
    it { is_expected.to respond_to :bookings_placement_date_id }
    it { is_expected.to respond_to :school }
    it { is_expected.to respond_to :bookings_subject_id }
  end

  context 'methods' do
    specify { expect(subject).to respond_to(:placement_date) }
    specify { expect(subject).to respond_to(:placement_date_subject) }
  end

  describe 'validations' do
    let(:school) { create(:bookings_school, availability_preference_fixed: true) }
    subject { described_class.new(urn: school.urn) }

    describe 'when the associated school has fixed availability' do
      before { subject.urn = create(:bookings_school, :with_fixed_availability_preference).urn }
      it { is_expected.to validate_presence_of(:bookings_placement_date_id) }
    end

    describe '#bookings_placement_dates_subject_id' do
      context 'when the placement date is not subject-specific' do
        let(:placement_date) { create(:bookings_placement_date, subject_specific: false) }

        before { subject.bookings_placement_date_id = placement_date.id }

        specify 'should not validate the presence of bookings_placement_dates_subject_id' do
          expect(subject).to be_valid
        end
      end

      context 'when the placement date is subject-specific' do
        let(:maths) { Bookings::Subject.find_by(name: 'Maths') }
        let(:english) { Bookings::Subject.find_by(name: 'English') }
        before { school.subjects << [maths] }

        let(:placement_date) do
          build(:bookings_placement_date, bookings_school: school, subject_specific: true).tap do |bpd|
            bpd.subjects << maths
            bpd.save
          end
        end

        before { subject.bookings_placement_date_id = placement_date.id }
        before { subject.valid? }

        specify 'should validate the presence of bookings_subject_id' do
          expect(subject).not_to be_valid
        end

        specify 'should fail validation with an appropriate message' do
          expect(subject.errors.messages[:bookings_subject_id]).to include("Choose a subject")
        end
      end
    end
  end

  describe 'methods' do
    describe '#placement_date' do
      it { is_expected.to respond_to(:placement_date) }

      before { allow(subject).to receive(:bookings_placement_date_id).and_return(1) }
      before { allow(Bookings::PlacementDate).to receive(:find_by).and_return('a') }


      specify 'should find the placement date via its id' do
        subject.placement_date
        expect(Bookings::PlacementDate).to have_received(:find_by).with(id: 1)
      end
    end

    describe '#placement_date_subject' do
      it { is_expected.to respond_to(:placement_date_subject) }

      before do
        subject.bookings_placement_date_id = 1
        subject.bookings_subject_id = 2
      end

      before { allow(Bookings::PlacementDateSubject).to receive(:find_by).and_return('a') }


      specify 'should find the placement date via its id' do
        subject.placement_date_subject
        expect(Bookings::PlacementDateSubject).to have_received(:find_by).with(
          bookings_placement_date_id: 1,
          bookings_subject_id: 2
        )
      end
    end

    describe '#subject_and_date_ids' do
      it { is_expected.to respond_to(:placement_date_subject) }

      let!(:bookings_placement_date) { create :bookings_placement_date, bookings_school: school }
      let!(:bookings_subject) { create :bookings_subject, schools: [school] }
      let!(:bookings_placement_dates_subject) do
        create(
          :bookings_placement_date_subject,
          bookings_placement_date: bookings_placement_date,
          bookings_subject: bookings_subject
        )
      end

      before do
        subject.bookings_placement_date_id = bookings_placement_date.id
        subject.bookings_subject_id = bookings_subject.id
      end

      specify 'should join the placement date and placement date subject ids separated by an underscore' do
        expect(subject.subject_and_date_ids).to eql(bookings_placement_dates_subject.combined_id)
      end
    end

    describe '#subject_and_date_ids=' do
      let!(:bookings_placement_date) { create :bookings_placement_date, bookings_school: school }
      let!(:bookings_subject) { create :bookings_subject, schools: [school] }
      let!(:bookings_placement_dates_subject) do
        create(
          :bookings_placement_date_subject,
          bookings_placement_date: bookings_placement_date,
          bookings_subject: bookings_subject
        )
      end

      before do
        subject.subject_and_date_ids = bookings_placement_dates_subject.combined_id
      end

      it 'sets the bookings_subject correctly' do
        expect(subject.bookings_subject).to eq bookings_subject
      end

      it 'sets the placement_date correctly' do
        expect(subject.placement_date).to eq bookings_placement_date
      end
    end
  end
end
