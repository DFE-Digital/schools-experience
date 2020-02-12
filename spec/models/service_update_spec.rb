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

  describe '.find' do
    before do
      allow(described_class).to receive(:data_path).and_return \
        Rails.root.join('spec', 'sample_data', 'service_updates')
    end

    let(:test_date) { '20200202' }
    subject { described_class.find test_date }

    it { is_expected.to have_attributes date: Date.parse('2020-02-02') }
    it { is_expected.to have_attributes title: 'Test Service Update' }
    it { is_expected.to have_attributes summary: 'Now you can apply for School Experience' }
    it { is_expected.to have_attributes content: /School Experience.\nYou can search/i }
  end
end
