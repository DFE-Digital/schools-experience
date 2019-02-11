require 'rails_helper'

describe Candidates::School do
  context '.find' do
    before { @school = create(:bookings_school) }

    context('with valid identifier') do
      it "will return school" do
        expect(described_class.find(@school.to_param)).to eq(@school)
      end
    end

    context('with invalid URN') do
      it "will raise ActiveRecord::RecordNotFound" do
        expect {
          described_class.find('abc123')
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  context '.phases' do
    before do
      @third = create(:bookings_phase, name: 'third', position: 3)
      @first = create(:bookings_phase, name: 'first', position: 1)
      @second = create(:bookings_phase, name: 'second', position: 2)

      @phases = described_class.phases
    end

    it 'should return an array of Phases ordered by the age period' do
      expect(@phases).to eq([
        [@first.id, @first.name],
        [@second.id, @second.name],
        [@third.id, @third.name]
      ])
    end
  end

  context '.subjects' do
    before do
      @later = create(:bookings_subject, name: 'Later')
      @earlier = create(:bookings_subject, name: 'Earlier')
      @subjects = described_class.subjects
    end

    it "should return a alphabetical array of subjects" do
      expect(@subjects).to eq([
        [@earlier.id, @earlier.name],
        [@later.id, @later.name]
      ])
    end
  end
end
