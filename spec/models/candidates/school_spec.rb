require 'rails_helper'

describe Candidates::School do
  describe '.find' do
    context('with valid identifier') do
      it "returns school" do
        school = create(:bookings_school)
        expect(described_class.find(school.to_param)).to eq(school)
      end
    end

    context('with invalid URN') do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          described_class.find('abc123')
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '.phases' do
    it 'returns an array of Phases ordered by the age period' do
      third = create(:bookings_phase, name: 'third', position: 3)
      first = create(:bookings_phase, name: 'first', position: 1)
      second = create(:bookings_phase, name: 'second', position: 2)

      expect(described_class.phases).to eq([
        [first.id, first.name],
        [second.id, second.name],
        [third.id, third.name]
      ])
    end
  end

  describe '.subjects' do
    it "returns a alphabetical array of subjects" do
      Bookings::Subject.destroy_all

      later = create(:bookings_subject, name: 'Later')
      earlier = create(:bookings_subject, name: 'Earlier')

      expect(described_class.subjects).to eq([
        [earlier.id, earlier.name],
        [later.id, later.name]
      ])
    end
  end
end
