require 'rails_helper'

describe Bookings::School, type: :model do
  describe 'Scopes' do
    subject { Bookings::School }

    context 'Full text searching on Name' do
      # provided by FullTextSearch
      it { is_expected.to respond_to(:search_by_name) }
    end

    context 'Geographic searching by Coordinates' do
      # provided by FullTextSearch
      it { is_expected.to respond_to(:close_to) }
    end

    context 'Filtering' do
      let!(:school_a) { create(:bookings_school) }
      let!(:school_b) { create(:bookings_school) }
      let!(:school_c) { create(:bookings_school) }

      let!(:maths) { create(:bookings_subject, name: "Maths") }
      let!(:physics) { create(:bookings_subject, name: "Physics") }
      let!(:chemistry) { create(:bookings_subject, name: "Chemistry") }
      let!(:biology) { create(:bookings_subject, name: "Biology") }

      before do
        school_a.subjects << [maths, physics]
        school_b.subjects << [maths, chemistry]
        school_c.subjects << [biology]
      end

      context 'By subject' do
        context 'when no subjects are supplied' do
          specify 'all schools should be returned' do
            [nil, "", []].each do |term|
              expect(subject.that_provide(term)).to include(school_a, school_b, school_c)
            end
          end
        end

        context 'when one or more subjects are supplied' do
          specify 'all schools that match any provided subject are returned' do
            {
              physics              => [school_a],
              maths                => [school_a, school_b],
              chemistry            => [school_b],
              biology              => [school_c],
              [chemistry, biology] => [school_b, school_c],
              [maths, chemistry]   => [school_a, school_b],
              [maths, biology]     => [school_a, school_b, school_c]
            }.each do |subjects, results|
              expect(subject.that_provide(subjects)).to match_array(results)
            end
          end
        end
      end
    end
  end

  describe 'Validation' do
    context 'Name' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_most(128) }
    end
  end

  describe 'Relationships' do
    specify do
      is_expected.to(
        have_many(:bookings_schools_subjects)
          .class_name("Bookings::SchoolsSubject")
          .with_foreign_key(:bookings_school_id)
          .inverse_of(:bookings_school)
      )
    end

    specify do
      is_expected.to(
        have_many(:subjects)
          .through(:bookings_schools_subjects)
          .class_name("Bookings::Subject")
          .source(:bookings_subject)
      )
    end
  end
end
