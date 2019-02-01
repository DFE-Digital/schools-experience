require 'rails_helper'

RSpec.describe Candidates::SchoolSearch do
  context '.new' do
    subject do
      described_class.new(
        query: 'this',
        distance: '3',
        max_fee: '30',
        phases: [1,2,3],
        subjects: [4,5,6]
      )
    end

    it 'assigns attributes' do
      expect(subject.query).to eq('this')
      expect(subject.distance).to eq(3)
      expect(subject.max_fee).to eq('30')
      expect(subject.phases).to eq([1,2,3])
      expect(subject.subjects).to eq([4,5,6])
    end
  end

  context '.subjects=' do
    context 'with blank strings' do
      before { subject.subjects = [1,'', 3] }

      it 'should remove blank strings' do
        expect(subject.subjects).to eq [1,3]
      end
    end

    context 'with nils' do
      before { subject.subjects = [1, 3, nil] }

      it 'should remove nils' do
        expect(subject.subjects).to eq [1,3]
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
      before { subject.phases = [1,'', 3] }

      it 'should remove blank strings' do
        expect(subject.phases).to eq [1,3]
      end
    end

    context 'with nils' do
      before { subject.phases = [1, 3, nil] }

      it 'should remove nils' do
        expect(subject.phases).to eq [1,3]
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
end
