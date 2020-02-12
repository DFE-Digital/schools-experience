require 'rails_helper'

describe ServiceUpdate, type: :model do
  let :attrs do
    {
      date: '20200601',
      title: 'Service Update A',
      summary: 'This is a short summary of Update A',
      content: "This is the full description of Update A.\n\nWith a longer explanation",
    }
  end

  describe 'data_path' do
    it "should be assigned" do
      expect(described_class.send(:data_path)).to eql \
        Rails.root.join('data', 'service_updates')
    end
  end

  describe 'attributes' do
    subject { described_class.new attrs }

    it { is_expected.to have_attributes date: Date.parse(attrs[:date]) }
    it { is_expected.to have_attributes title: attrs[:title] }
    it { is_expected.to have_attributes summary: attrs[:summary] }
    it { is_expected.to have_attributes content: attrs[:content] }
  end

  context 'with test data' do
    before do
      allow(described_class).to receive(:data_path).and_return \
        Rails.root.join('spec', 'sample_data', 'service_updates')
    end

    let(:test_date) { '20200202' }
    let(:second_date) { '20200203' }

    describe '.find' do
      subject { described_class.find test_date }
      it { is_expected.to have_attributes date: Date.parse('2020-02-02') }
      it { is_expected.to have_attributes title: 'Test Service Update' }
      it { is_expected.to have_attributes summary: 'Now you can apply for School Experience' }
      it { is_expected.to have_attributes content: /School Experience.\nYou can search/i }
    end

    describe '.dates' do
      subject { described_class.dates }
      it { is_expected.to eql [test_date, second_date] }
    end

    describe '.latest_date' do
      before do
        allow(described_class).to receive(:dates).and_return \
          %w(20200101 20200202 20200203)
      end

      subject { described_class.latest_date }
      it { is_expected.to eql '20200203' }
    end

    describe '.latest' do
      before { allow(described_class).to receive(:latest_date) { test_date } }
      subject! { described_class.latest }
      it { is_expected.to have_attributes date: Date.parse(test_date) }
      it { expect(described_class).to have_received(:latest_date) }
    end

    describe '#==' do
      let(:other) { described_class.new attrs }
      subject { described_class.new attrs }
      it { is_expected.to eq other }
    end

    describe '.all' do
      let(:first) { described_class.find test_date }
      let(:second) { described_class.find second_date }
      subject { described_class.all }
      it { is_expected.to eq [first, second] }
    end
  end
end
