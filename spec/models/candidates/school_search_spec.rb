require 'rails_helper'

RSpec.describe Candidates::SchoolSearch do
  context '.new' do
    subject do
      described_class.new(
        query: 'this',
        location: 'manchester',
        distance: '3',
        max_fee: '30',
        phases: [1, 2, 3],
        subjects: [4, 5, 6],
        dbs_policies: [2],
        disability_confident: '1',
        parking: '1'
      )
    end

    it 'assigns attributes' do
      expect(subject.query).to eq('this')
      expect(subject.distance).to eq(3)
      expect(subject.location).to eq('manchester')
      expect(subject.max_fee).to eq('30')
      expect(subject.phases).to eq([1, 2, 3])
      expect(subject.subjects).to eq([4, 5, 6])
      expect(subject.dbs_policies).to eq([2])
      expect(subject.disability_confident).to eq('1')
      expect(subject.parking).to eq('1')
    end
  end

  context 'delegation' do
    it { expect(subject).to delegate_method(:valid?).to(:school_search) }
    it { expect(subject).to delegate_method(:errors).to(:school_search) }
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

  context '.dbs_policies=' do
    context 'with blank strings' do
      before { subject.dbs_policies = [1, '', 3] }

      it 'should remove blank strings' do
        expect(subject.dbs_policies).to eq [1, 3]
      end
    end

    context 'with nils' do
      before { subject.dbs_policies = [1, 3, nil] }

      it 'should remove nils' do
        expect(subject.dbs_policies).to eq [1, 3]
      end
    end

    context 'with single values' do
      before { subject.dbs_policies = 1 }

      it 'convert single values to arrays' do
        expect(subject.dbs_policies).to eq [1]
      end
    end

    context 'with string values' do
      before { subject.dbs_policies = ['1', '2', 3] }

      it 'should convert to integers' do
        expect(subject.dbs_policies).to eq [1, 2, 3]
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

    context 'with latitude and distance' do
      subject { described_class.new(latitude: '-2.241', distance: '10') }
      it('should be invalid') { expect(subject.valid_search?).to be false }
    end

    context 'with longitude and distance' do
      subject { described_class.new(longitude: '53.481', distance: '10') }
      it('should be invalid') { expect(subject.valid_search?).to be false }
    end

    context 'with latitude, longitude and distance' do
      subject do
        described_class.new(
          distance: '10', longitude: '53.481', latitude: '-2.241'
        )
      end

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
      expect(subject.subject_names).to match_array([@first.name, @third.name])
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
      expect(subject.phase_names).to match_array([@first.name, @third.name])
    end
  end

  context '.dbs_policies_names' do
    subject { described_class.new(dbs_policies: [1, 2]) }

    it "will return an array of phases" do
      expect(subject.dbs_policies_names).to match_array(['In school', 'Not required'])
    end
  end
end
