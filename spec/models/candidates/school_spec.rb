require 'rails_helper'

RSpec.describe Candidates::School do
  context '.new' do
    before do
      @search = Candidates::School.new(
        query: 'this',
        distance: '3',
        fees: '>30',
        phase: ['11-16', '16-18'],
        subject: ['Maths', 'English'])
    end

    it 'assigns attributes' do
      expect(@search.query).to eq('this')
      expect(@search.distance).to eq(3)
      expect(@search.fees).to eq('>30')
      expect(@search.phase).to eq(['11-16', '16-18'])
      expect(@search.subject).to eq(['Maths', 'English'])
    end
  end

  context '.results' do
    before { @search = Candidates::School.new(query: 'Test School') }

    it 'returns stubbed array' do
      expect(@search.results).to eq([])
    end
  end

  context '.filtering_results' do
    context 'for blank search' do
      before { @search = Candidates::School.new }

      it "will be false" do
        expect(@search.filtering_results?).to be_falsey
      end
    end

    context 'for valid search' do
      before { @search = Candidates::School.new(query:"test") }

      it "will be true" do
        expect(@search.filtering_results?).to be_truthy
      end
    end
  end
end