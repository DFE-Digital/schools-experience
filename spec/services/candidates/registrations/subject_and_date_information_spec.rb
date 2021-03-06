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

        subject do
          described_class.new \
            urn: school.urn,
            bookings_placement_date_id: placement_date.id
        end

        it { is_expected.not_to validate_presence_of :bookings_subject_id }
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

        context 'and no date subject specified' do
          subject do
            described_class.new \
              urn: school.urn,
              bookings_placement_date_id: placement_date.id
          end

          specify 'should validate the presence of bookings_subject_id' do
            is_expected.to \
              validate_presence_of(:bookings_subject_id)
                .with_message('Choose a subject')
          end
        end

        context 'and invalid date subject specified' do
          # race scenario if school removes subject from date whilst
          # candidate is viewing it

          subject do
            described_class.new \
              urn: school.urn,
              bookings_placement_date_id: placement_date.id,
              bookings_subject_id: 999_999
          end

          specify 'should validate the presence of bookings_placement_date_subject' do
            is_expected.not_to be_valid
            expect(subject.errors.full_messages).to include('Choose a subject')
          end
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

    describe '#date_and_subject_ids' do
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
        expect(subject.date_and_subject_ids).to eql(bookings_placement_dates_subject.date_and_subject_id)
      end
    end

    describe '#date_and_subject_ids=' do
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
        subject.date_and_subject_ids = bookings_placement_dates_subject.date_and_subject_id
      end

      it 'sets the bookings_subject correctly' do
        expect(subject.bookings_subject).to eq bookings_subject
      end

      it 'sets the placement_date correctly' do
        expect(subject.placement_date).to eq bookings_placement_date
      end
    end

    describe '#has_primary_dates?' do
      subject { described_class.new }
      context 'when primary dates are present' do
        before { allow(subject).to receive(:primary_placement_dates).and_return(%w[yes]) }

        it { is_expected.to have_primary_dates }
      end

      context 'when no primary dates are present' do
        before { allow(subject).to receive(:primary_placement_dates).and_return([]) }

        it { is_expected.not_to have_primary_dates }
      end
    end

    describe '#has_secondary_dates?' do
      subject { described_class.new }
      context 'when secondary dates are present' do
        before { allow(subject).to receive(:secondary_placement_dates_grouped_by_date).and_return(%w[yes]) }

        it { is_expected.to have_secondary_dates }
      end

      context 'when no secondary dates are present' do
        before { allow(subject).to receive(:secondary_placement_dates_grouped_by_date).and_return({}) }

        it { is_expected.not_to have_secondary_dates }
      end
    end

    describe '#has_primary_and_secondary_dates?' do
      subject { described_class.new }
      context 'when secondary dates are present' do
        before { allow(subject).to receive(:primary_placement_dates).and_return(%w[yes]) }
        before { allow(subject).to receive(:secondary_placement_dates_grouped_by_date).and_return(%w[yes]) }

        it { is_expected.to have_primary_and_secondary_dates }
      end

      context 'when no secondary dates are present' do
        before { allow(subject).to receive(:secondary_placement_dates_grouped_by_date).and_return({}) }
        before { allow(subject).to receive(:primary_placement_dates).and_return([]) }

        it { is_expected.not_to have_primary_and_secondary_dates }
      end
    end
  end
end
