require 'rails_helper'

RSpec.describe Candidate::School do
  context '.new' do
    before do
      @search = Candidate::School.new(
        query: 'this',
        distance: '3',
        fees: '0',
        phase: 'X',
        subject: 'Maths')
    end

    it 'assigns attributes' do
      expect(@search.query).to eq('this')
      expect(@search.distance).to eq(3)
      expect(@search.fees).to eq(false)
      expect(@search.phase).to eq('X')
      expect(@search.subject).to eq('Maths')
    end
  end

  context '.results' do
    before { @search = Candidate::School.new(query: 'Test School') }

    it 'returns stubbed array' do
      expect(@search.results).to eq([])
    end
  end

  context '.filtering_results' do
    context 'for blank search' do
      before { @search = Candidate::School.new }

      it "will be false" do
        expect(@search.filtering_results?).to be_falsey
      end
    end

    context 'for valid search' do
      before { @search = Candidate::School.new(query:"test") }

      it "will be true" do
        expect(@search.filtering_results?).to be_truthy
      end
    end
  end
end