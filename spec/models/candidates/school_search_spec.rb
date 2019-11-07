require 'rails_helper'

RSpec.describe Candidates::SchoolSearch do
  let!(:primary_phase) { create :bookings_phase, :primary }
  let!(:secondary_phase) { create :bookings_phase, :secondary }
  let!(:college_phase) { create :bookings_phase, :college }

  context '.new' do
    subject do
      described_class.new(
        query: 'this',
        location: 'manchester',
        distance: '3',
        max_fee: '30',
        phases: [1, 2, 3],
        subjects: [4, 5, 6]
      )
    end

    it 'assigns attributes' do
      expect(subject.query).to eq('this')
      expect(subject.distance).to eq(3)
      expect(subject.location).to eq('manchester')
      expect(subject.max_fee).to eq('30')
      expect(subject.phases).to eq([1, 2, 3])
      expect(subject.subjects).to eq([4, 5, 6])
    end
  end

  context 'validation' do
    it { is_expected.to validate_inclusion_of(:age_group).in_array %w(primary secondary) }
    it { is_expected.to validate_length_of(:location).is_at_least(3).allow_nil }
  end

  context 'delegation' do
    it { expect(subject).to delegate_method(:location_name).to(:school_search) }
    it { expect(subject).to delegate_method(:has_coordinates?).to(:school_search) }
  end

  context '.subjects=' do
    context 'with blank strings' do
      before { subject.subjects = [1, '', 3] }

      it 'should remove blank strings' do
        expect(subject.subjects).to eq [1, 3]
      end
    end

    context 'with nils' do
      before { subject.subjects = [1, 3, nil] }

      it 'should remove nils' do
        expect(subject.subjects).to eq [1, 3]
      end
    end

    context 'with single values' do
      before { subject.subjects = 1 }

      it 'convert single values to arrays' do
        expect(subject.subjects).to eq [1]
      end
    end

    context 'with string values' do
      before { subject.subjects = ['1', '2', 3] }

      it 'should convert to integers' do
        expect(subject.subjects).to eq [1, 2, 3]
      end
    end
  end

  context '.phases=' do
    context 'with blank strings' do
      before { subject.phases = [1, '', 3] }

      it 'should remove blank strings' do
        expect(subject.phases).to eq [1, 3]
      end
    end

    context 'with nils' do
      before { subject.phases = [1, 3, nil] }

      it 'should remove nils' do
        expect(subject.phases).to eq [1, 3]
      end
    end

    context 'with single values' do
      before { subject.phases = 1 }

      it 'convert single values to arrays' do
        expect(subject.phases).to eq [1]
      end
    end

    context 'with string values' do
      before { subject.phases = ['1', '2', 3] }

      it 'should convert to integers' do
        expect(subject.phases).to eq [1, 2, 3]
      end
    end
  end

  context '.age_group_options' do
    context 'primary age group' do
      subject do
        described_class.age_group_options.detect { |o| o.name == 'primary' }
      end

      it 'sets the phases correctly' do
        expect(subject.phases).to eq [primary_phase.id]
      end
    end

    context 'secondary age group' do
      subject do
        described_class.age_group_options.detect { |o| o.name == 'secondary' }
      end

      it 'sets the phases correctly' do
        expect(subject.phases).to eq [secondary_phase, college_phase].map(&:id)
      end
    end
  end

  context 'max_fee=' do
    context 'with known value' do
      before { subject.max_fee = '30' }

      it('should be 30') do
        expect(subject.max_fee).to eq '30'
      end
    end

    context 'with known value as integer' do
      before { subject.max_fee = 30 }

      it('should be 30') do
        expect(subject.max_fee).to eq '30'
      end
    end

    context 'with unknown value' do
      before { subject.max_fee = '20000' }

      it('should be blank') do
        expect(subject.max_fee).to eq ''
      end
    end

    context 'with blank value' do
      before { subject.max_fee = '' }

      it('should be blank') do
        expect(subject.max_fee).to eq ''
      end
    end

    context 'with nil value' do
      before { subject.max_fee = nil }

      it('should be blank') do
        expect(subject.max_fee).to eq ''
      end
    end
  end

  context '#age_group=' do
    context 'when "primary"' do
      before { subject.age_group = 'primary' }

      it('sets the phases') do
        expect(subject.phases).to eq [primary_phase.id]
      end

      it('sets the age_group') do
        expect(subject.age_group).to eq 'primary'
      end
    end

    context 'when "seconday"' do
      before { subject.age_group = 'secondary' }

      it('sets the phases') do
        expect(subject.phases).to eq [secondary_phase.id, college_phase.id]
      end

      it('sets the age_group') do
        expect(subject.age_group).to eq 'secondary'
      end
    end

    context 'when other' do
      before { subject.age_group = 'other' }

      it('sets phases to empty') do
        expect(subject.phases).to eq []
      end

      it('sets age_group to nil') do
        expect(subject.age_group).to eq nil
      end
    end
  end

  context '#age_group' do
    context 'when primary phases selected' do
      before { subject.phases = [primary_phase.id] }

      it('returns primary') do
        expect(subject.age_group).to eq 'primary'
      end
    end

    context 'when secondary phases selected' do
      before { subject.phases = [secondary_phase.id, college_phase.id] }

      it('returns secondary') do
        expect(subject.age_group).to eq 'secondary'
      end
    end

    context 'when other' do
      let(:other_phase) { create :bookings_phase, name: 'Elderly' }

      before { subject.phases = [other_phase.id] }

      it('returns nil') do
        expect(subject.age_group).to eq nil
      end
    end
  end

  context '#secondary_search?' do
    context 'when the age_group is secondary' do
      subject { described_class.new age_group: 'secondary' }

      it { is_expected.to be_a_secondary_search }
    end

    context 'when the age_group is primary' do
      subject { described_class.new age_group: 'primary' }

      it { is_expected.not_to be_a_secondary_search }
    end
  end

  context '.results' do
    subject { described_class.new(query: 'Test School') }

    it 'returns array of Schools' do
      expect(subject.results).to be_kind_of Enumerable
    end
  end

  context '.total_count' do
    subject { described_class.new(query: 'Test School') }

    it 'returns array of Schools' do
      expect(subject.total_count).to be_kind_of Integer
    end
  end

  context '.valid_search?' do
    context 'with query' do
      subject { described_class.new(query: 'Test School') }
      it('should be valid') { expect(subject.valid_search?).to be true }
    end

    context 'with only location' do
      subject { described_class.new(location: 'Manchester', distance: '') }
      it('should be invalid') { expect(subject.valid_search?).to be false }
    end

    context 'with only distance' do
      subject { described_class.new(distance: '10') }
      it('should be invalid') { expect(subject.valid_search?).to be false }
    end

    context 'with location and distance' do
      subject { described_class.new(location: 'Manchester', distance: '10') }
      it('should be valid') { expect(subject.valid_search?).to be true }
    end

    context 'with query, location and distance' do
      subject do
        described_class.new(
          query: 'test',
          location: 'Manchester',
          distance: '10'
        )
      end

      it('should be valid') { expect(subject.valid_search?).to be true }
    end
  end

  context '.filtering_results' do
    context 'for blank search' do
      subject { described_class.new }

      it "will be false" do
        expect(subject.filtering_results?).to be_falsey
      end
    end

    context 'for valid search' do
      subject { described_class.new(query: "test") }

      it "will be true" do
        expect(subject.filtering_results?).to be_truthy
      end
    end
  end

  context '.subject_names' do
    before do
      @first = create(:bookings_subject)
      @second = create(:bookings_subject)
      @third = create(:bookings_subject)
    end

    subject { described_class.new(subjects: [@first.id, @third.id]) }

    it "will return an array of subjects" do
      expect(subject.subject_names).to eq([@first.name, @third.name])
    end
  end

  context '.phase_names' do
    before do
      @first = create(:bookings_phase)
      @second = create(:bookings_phase)
      @third = create(:bookings_phase)
    end

    subject { described_class.new(phases: [@first.id, @third.id]) }

    it "will return an array of phases" do
      expect(subject.phase_names).to eq([@first.name, @third.name])
    end
  end
end
