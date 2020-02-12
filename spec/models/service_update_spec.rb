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

  describe 'attributes' do
    subject { described_class.new attrs }

    it { is_expected.to have_attributes date: Date.parse(attrs[:date]) }
    it { is_expected.to have_attributes title: attrs[:title] }
    it { is_expected.to have_attributes summary: attrs[:summary] }
    it { is_expected.to have_attributes content: attrs[:content] }
  end
end
