require 'rails_helper'

describe 'Concerns' do
  describe 'FullTextSearch' do

    describe '.search_by_name' do
      subject { School }

      let!(:primary) { subject.create(name: "Springfield Primary School") }
      let!(:secondary) { subject.create(name: "Springhead Secondary School") }
      let!(:grammar) { subject.create(name: "Hulme Grammar School") }

      specify 'should match on word prefixes' do
        expect(subject.search_by_name("Spring")).to include(primary, secondary)
      end

      specify 'should match on whole words at any position' do
        expect(subject.search_by_name("School")).to include(primary, secondary, grammar)
        expect(subject.search_by_name("Secondary")).to include(secondary)
        expect(subject.search_by_name("Grammar")).to include(grammar)
      end

      specify 'should be case insensitive' do
        %w{secondary Secondary sEcOndAry SECONDARY}.each do |term|
          expect(subject.search_by_name(term)).to include(secondary)
        end
      end

    end
  end
end
