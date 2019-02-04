require 'rails_helper'

RSpec.describe Candidates::SchoolSearch do
  context '.new' do
    subject do
      described_class.new(
        query: 'this',
        distance: '3',
        fees: '>30',
        phase: ['11-16', '16-18'],
        subject: %w{Maths English}
      )
    end

    it 'assigns attributes' do
      expect(subject.query).to eq('this')
      expect(subject.distance).to eq(3)
      expect(subject.fees).to eq('>30')
      expect(subject.phase).to eq(['11-16', '16-18'])
      expect(subject.subject).to eq(%w{Maths English})
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
