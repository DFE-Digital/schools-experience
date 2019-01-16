require 'rails_helper'

RSpec.describe School, type: :model do

  describe 'Validation' do

    context 'Name' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_most(128) }
    end

  end

  describe 'Searching' do

    context 'By name' do

      subject { School }

      let!(:primary) { subject.create(name: "Springfield Primary School") }
      let!(:secondary) { subject.create(name: "Springhead Secondary School") }
      let!(:grammar) { subject.create(name: "Hulme Grammar School") }

      specify 'should match word prefixes' do
        expect(subject.search_by_name("Spring")).to include(primary, secondary)
      end

      specify 'should match whole words at any position' do
        expect(subject.search_by_name("School")).to include(primary, secondary, grammar)
        expect(subject.search_by_name("Secondary")).to include(secondary)
        expect(subject.search_by_name("Grammar")).to include(grammar)
      end

      specify 'should be case insensitive' do
        expect(subject.search_by_name("secondary")).to include(secondary)
      end

    end

  end

end
